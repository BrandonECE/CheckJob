// lib/presentation/controllers/employee/employee_controller.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:check_job/domain/entities/enities.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/repositories/employee_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';

class EmployeeController extends GetxController {
  final EmployeeRepository _employeeRepository;
  final AdminController _adminController;
  StreamSubscription? _employeesSubscription;

  EmployeeController({
    required EmployeeRepository employeeRepository,
    required AdminController adminController,
  })  : _employeeRepository = employeeRepository,
        _adminController = adminController;

  final RxList<EmployeeEntity> employees = <EmployeeEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isButtonDeleteLoading = false.obs;
  final Rx<EmployeeEntity?> selectedEmployee = Rx<EmployeeEntity?>(null);

  @override
  void onInit() {
    _loadEmployees();
    super.onInit();
  }

  @override
  void onClose() {
    _employeesSubscription?.cancel();
    super.onClose();
  }

  void _loadEmployees() {
    isLoading.value = true;
    _employeesSubscription = _employeeRepository.getEmployees().listen(
      (employeesList) {
        employees.assignAll(employeesList);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Error al cargar empleados: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> refreshEmployees() async {
    try {
      isLoading.value = true;
      final employeesList = await _employeeRepository.getEmployeesOnce();
      employees.assignAll(employeesList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar empleados: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeDeleteButtonValue(bool isButtonDeleteLoading) {
    this.isButtonDeleteLoading.value = isButtonDeleteLoading;
  }

  Future<void> selectEmployee(String employeeID) async {
    try {
      isLoading.value = true;
      selectedEmployee.value = await _employeeRepository.getEmployeeWithTasks(employeeID);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Error al cargar empleado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void changeLoadingValue(bool isLoadingNewValue) {
    isLoading.value = isLoadingNewValue;
  }

  void clearSelection() {
    selectedEmployee.value = null;
  }

  Future<void> createEmployee({
    required String name,
    required String email,
    required String phone,
    Uint8List? photoData,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      final employee = EmployeeEntity(
        employeesID: _generateEmployeeId(),
        name: name,
        email: email,
        phone: phone,
        isActive: false,
        createdAt: DateTime.now(),
        tasks: [],
      );

      // 1) Crear empleado
      await _employeeRepository.createEmployee(employee, photoData);

      // 2) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'employee_created',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: employee.name,
        );
      } catch (auditError) {
        // 3) Si falla el audit, revertir (borrar empleado creado)
        try {
          await _employeeRepository.deleteEmployee(employee.employeesID);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la creación.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se revirtió la creación.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Empleado creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshEmployees();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el empleado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEmployee({
    required String employeeID,
    required String name,
    required String email,
    required String phone,
    Uint8List? photoData,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Guardar el estado anterior para posible rollback
      final employeeIndex = employees.indexWhere((e) => e.employeesID == employeeID);
      if (employeeIndex == -1) throw Exception('Empleado no encontrado');

      final oldEmployee = employees[employeeIndex];
      final updatedEmployee = oldEmployee.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // 2) Actualizar
      await _employeeRepository.updateEmployee(updatedEmployee, photoData);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'employee_updated',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: oldEmployee.name,
        );
      } catch (auditError) {
        // 4) Si falla audit, revertir a oldEmployee
        try {
          await _employeeRepository.updateEmployee(oldEmployee, null);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la actualización.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se revirtió la actualización.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Empleado actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshEmployees();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el empleado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployee(String employeeID, String employeeName) async {
    try {
      isLoading.value = true;
      isButtonDeleteLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // Verificar si el empleado tiene tareas activas
      final employee = await _employeeRepository.getEmployeeWithTasks(employeeID);
      final activeTasks = employee.inProgressTasks;

      if (activeTasks.isNotEmpty) {
        Get.snackbar(
          'Error',
          'No se puede eliminar el empleado porque tiene tareas activas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 1) Obtener snapshot actual del empleado para poder restaurarlo si hace falta
      final employeeIndex = employees.indexWhere((e) => e.employeesID == employeeID);
      if (employeeIndex == -1) throw Exception('Empleado no encontrado');

      final existingEmployee = employees[employeeIndex];

      // 2) Borrar
      await _employeeRepository.deleteEmployee(employeeID);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'employee_deleted',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: employeeName,
        );
      } catch (auditError) {
        // 4) Si falla audit, intentar restaurar el documento eliminado
        try {
          await _employeeRepository.createEmployee(existingEmployee, null);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni restaurar el empleado.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se restauró el empleado eliminado.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Empleado eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshEmployees();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el empleado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isButtonDeleteLoading.value = false;
    }
  }

  // Helper methods para acceder a datos del empleado seleccionado
  List<TaskEntity> get selectedEmployeeTasks => selectedEmployee.value?.tasks ?? [];
  bool get isSelectedEmployeeActive => selectedEmployee.value?.isActive ?? false;
  int get selectedEmployeeCompletedTasks => selectedEmployee.value?.completedTasks.length ?? 0;
  int get selectedEmployeeInProgressTasks => selectedEmployee.value?.inProgressTasks.length ?? 0;

  String _generateEmployeeId() {
    return 'emp_${DateTime.now().millisecondsSinceEpoch}';
  }
}