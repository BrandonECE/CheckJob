// lib/presentation/controllers/admin_task_controller.dart
import 'dart:async';
import 'package:check_job/config/routes.dart';
import 'package:check_job/domain/repositories/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/repositories/material_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';
import '../../../domain/entities/enities.dart';

class AdminTaskController extends GetxController {
  final TaskRepository _taskRepository;
  final InvoiceRepository _invoiceRepository;
  final MaterialRepository _materialRepository;
  final AdminController _adminController;
  final EmployeeRepository _employeeRepository;

  StreamSubscription? _tasksSubscription;

  AdminTaskController({
    required TaskRepository taskRepository,
    required InvoiceRepository invoiceRepository,
    required MaterialRepository materialRepository,
    required AdminController adminController,
    required EmployeeRepository employeeRepository,
  }) : _taskRepository = taskRepository,
       _invoiceRepository = invoiceRepository,
       _materialRepository = materialRepository,
       _adminController = adminController,
       _employeeRepository = employeeRepository;

  // Observables
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isButtonLoading = false.obs;
  final RxBool isPrintButtonLoading = false.obs;
  final Rx<TaskEntity?> selectedTask = Rx<TaskEntity?>(null);
  final RxString taskIdError = ''.obs;

  @override
  void onInit() {
    _loadTasks();
    super.onInit();
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    super.onClose();
  }

  // -----------------------
  // Carga inicial / refresco
  // -----------------------
  Future<void> _loadTasks() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _tasksSubscription = _taskRepository.getTasks().listen(
      (tasksList) {
        tasks.assignAll(tasksList);
        isLoading.value = false;
      },
      onError: (err) {
        isLoading.value = false;
        _showErrorSnackbar('Error al cargar tareas: $err');
      },
    );
  }

  Future<void> refreshTasks() async {
    try {
      isLoading.value = true;
      final tasksList = await _taskRepository.getTasksOnce();
      tasks.assignAll(tasksList);
    } catch (e) {
      _showErrorSnackbar('Error al actualizar tareas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------
  // Selección de tarea con carga de foto
  // -----------------------
  void selectTask(TaskEntity task) async {
    selectedTask.value = task;
    isLoading.value = true;

    // Cargar foto del empleado en segundo plano
    await _loadEmployeePhoto(task);
  }

  Future<void> _loadEmployeePhoto(TaskEntity task) async {
    try {
      final photo = await _employeeRepository.getEmployeePhoto(
        task.assignedEmployeeID,
      );
      if (photo != null) {
        task.setPhoto(photo);
        // Actualizar la tarea seleccionada para notificar a la UI
        selectedTask.value = task;
      }
    } catch (e) {
      print('Error cargando foto del empleado: $e');
    } finally {
      Get.toNamed(Routes.myAdminTaskDetailView);
    }
  }

  void updateIsLoading(bool isLoading) {
    this.isLoading.value = isLoading;
  }

  void updateIsPrintButtonLoading(bool isLoading) {
    isPrintButtonLoading.value = isLoading;
  }

  // -----------------------
  // Resto de métodos (igual que antes)
  // -----------------------
  Future<bool> checkTaskIdExists(String taskId) async {
    try {
      taskIdError.value = '';
      final exists = await _taskRepository.checkTaskIdExists(taskId);
      if (exists) {
        taskIdError.value = 'Ya existe una tarea con este ID';
      }
      return exists;
    } catch (e) {
      taskIdError.value = 'Error al verificar ID: $e';
      return true;
    }
  }

  Future<void> createTask({
    required String taskId,
    required String title,
    required String description,
    required String clientID,
    required String clientName,
    required String assignedEmployeeID,
    required String assignedEmployeeName,
    required String status,
    required double amount,
    required DateTime dueDate,
    required List<Map<String, dynamic>> materialsUsed,
  }) async {
    isButtonLoading.value = true;
    try {
      final exists = await checkTaskIdExists(taskId);
      if (exists) throw Exception('Ya existe una tarea con el ID: $taskId');

      print(materialsUsed);

      final task = TaskEntity(
        taskID: taskId,
        title: title,
        description: description,
        status: status,
        assignedEmployeeID: assignedEmployeeID,
        assignedEmployeeName: assignedEmployeeName,
        clientID: clientID,
        clientName: clientName,
        createdAt: Timestamp.now(),
        completedAt: null,
        clientFeedback: null,
        materialsUsed: materialsUsed
            .map(
              (m) => TaskMaterialUsedEntity(
                materialID: m['materialID'] as String,
                materialName: m['materialName'] as String,
                quantity: m['quantity'] is int
                    ? m['quantity'] as int
                    : (m['quantity'] as num).toInt(),
                unit: m['unit'] as String,
              ),
            )
            .toList(),
        comment: null,
      );

      await _taskRepository.createTask(task);

      final invoice = InvoiceEntity(
        invoicesID: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        taskID: taskId,
        clientName: clientName,
        clientID: clientID,
        amount: amount,
        status: 'pending',
        dueDate: Timestamp.fromDate(dueDate),
        createdAt: Timestamp.now(),
      );
      await _invoiceRepository.createInvoice(invoice);

      await _updateMaterialsStock(materialsUsed, isRevert: false);

      try {
        await _logAuditAction('task_created', taskId);
      } catch (auditError) {
        try {
          await _taskRepository.deleteTask(taskId);
          await _invoiceRepository.deleteInvoice(invoice.invoicesID);
          await _updateMaterialsStock(materialsUsed, isRevert: true);
        } catch (rollbackError) {
          _showErrorSnackbar(
            'Error crítico: audit y rollback fallaron: $auditError / $rollbackError',
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se revirtió la creación.',
        );
      }

      Get.back();
      _showSuccessSnackbar('Tarea creada correctamente');
      await refreshTasks();
    } catch (e) {
      _showErrorSnackbar('No se pudo crear la tarea: $e');
    } finally {
      isButtonLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    isButtonLoading.value = true;
    try {
      final prevTask = await _taskRepository.getTaskById(taskId);
      if (prevTask == null) {
        throw Exception('Tarea no encontrada para actualizar');
      }
      final oldStatus = prevTask.status;

      await Future.delayed(const Duration(milliseconds: 700));
      await _taskRepository.updateTaskStatus(taskId, newStatus);

      try {
        await _logAuditAction('task_updated', taskId);
      } catch (auditError) {
        try {
          await _taskRepository.updateTaskStatus(taskId, oldStatus);
        } catch (rollbackError) {
          _showErrorSnackbar(
            'Error crítico: audit y rollback fallaron: $auditError / $rollbackError',
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se revirtió el estado.',
        );
      }

      try {
        Get.back();
      } catch (_) {}
      _showSuccessSnackbar('Estado actualizado correctamente');
      await refreshTasks();
    } catch (e) {
      _showErrorSnackbar('No se pudo actualizar el estado: $e');
    } finally {
      isButtonLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    isButtonLoading.value = true;
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task == null) throw Exception('Tarea no encontrada');

      final invoices = await _invoiceRepository.getInvoicesOnce();
      final invoice = invoices.firstWhere(
        (inv) => inv.taskID == taskId,
        orElse: () =>
            throw Exception('Factura no encontrada para la tarea: $taskId'),
      );

      final materialsUsed = task.materialsUsed
          .map(
            (m) => {
              'materialName': m.materialName,
              'quantity': m.quantity,
              'unit': m.unit,
              'materialID': m.materialID,
            },
          )
          .toList();

      await _taskRepository.deleteTask(taskId);
      await _invoiceRepository.deleteInvoice(invoice.invoicesID);
      await _updateMaterialsStock(materialsUsed, isRevert: true);

      try {
        await _logAuditAction('task_deleted', taskId);
      } catch (auditError) {
        try {
          await _taskRepository.createTask(task);
          await _invoiceRepository.createInvoice(invoice);
          await _updateMaterialsStock(materialsUsed, isRevert: false);
        } catch (rollbackError) {
          _showErrorSnackbar(
            'Error crítico: audit y rollback fallaron: $auditError / $rollbackError',
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se intentó restaurar la tarea.',
        );
      }

      try {
        Get.back();
      } catch (_) {}
      try {
        Get.back();
      } catch (_) {}

      _showSuccessSnackbar('Tarea eliminada correctamente');
      await refreshTasks();
    } catch (e) {
      _showErrorSnackbar('No se pudo eliminar la tarea: $e');
    } finally {
      isButtonLoading.value = false;
    }
  }

  // -----------------------
  // Helpers
  // -----------------------
  Future<void> _updateMaterialsStock(
    List<Map<String, dynamic>> materialsUsed, {
    required bool isRevert,
  }) async {
    try {
      final allMaterials = await _materialRepository.getMaterialsOnce();

      for (final materialUsed in materialsUsed) {
        final materialName = materialUsed['materialName'] as String;
        final quantity = materialUsed['quantity'] is int
            ? materialUsed['quantity'] as int
            : (materialUsed['quantity'] as num).toInt();

        final currentMaterial = allMaterials.firstWhere(
          (m) => m.name == materialName,
          orElse: () =>
              throw Exception('Material no encontrado: $materialName'),
        );

        final newStock = isRevert
            ? currentMaterial.currentStock + quantity
            : currentMaterial.currentStock - quantity;

        final updatedMaterial = currentMaterial.copyWith(
          currentStock: newStock,
          updatedAt: DateTime.now(),
        );

        await _materialRepository.updateMaterial(updatedMaterial);
      }
    } catch (e) {
      throw Exception('Error al actualizar stock de materiales: $e');
    }
  }

  Future<void> _logAuditAction(String action, String target) async {
    try {
      await AuditLogController.logAction(
        action: action,
        actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
        target: target,
      );
    } catch (e) {
      rethrow;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void clearSelection() {
    selectedTask.value = null;
  }
}
