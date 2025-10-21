import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/notification_entity.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/notification_repository.dart';
import 'package:check_job/domain/services/employee_service.dart';

class UserTaskController extends GetxController {
  final TaskRepository _taskRepository;
  final NotificationRepository _notificationRepository;
  final EmployeeService _employeeService;
  final InvoiceRepository _invoiceRepository;

  UserTaskController({
    required TaskRepository taskRepository,
    required NotificationRepository notificationRepository,
    required EmployeeService employeeService,
    required InvoiceRepository invoiceRepository,
  }) : _taskRepository = taskRepository,
       _notificationRepository = notificationRepository,
       _employeeService = employeeService,
       _invoiceRepository = invoiceRepository;

  final Rx<TaskEntity?> selectedTask = Rx<TaskEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString searchError = ''.obs;
  final RxBool isSubmittingFeedback = false.obs;
  final RxString tempComment = ''.obs;

  Future<void> searchTaskById(String taskId) async {
    try {
      isLoading.value = true;
      searchError.value = '';

      final task = await _taskRepository.getTaskById(taskId);

      if (task == null) {
        searchError.value = 'No se encontró ninguna tarea con el ID: $taskId';
        selectedTask.value = null;
      } else {
        try {
          print("CLIENT ID: ${task.assignedEmployeeID}");
          final photo = await _employeeService.getEmployeePhoto(
            task.assignedEmployeeID,
          );
          if (photo != null) {
            task.setPhoto(photo);
          }
        } catch (e) {
          print('Error cargando foto del empleado: $e');
        }

        selectedTask.value = task;
        searchError.value = '';
      }
    } catch (e) {
      searchError.value = 'Error al buscar tarea: $e';
      selectedTask.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitTaskFeedback({
    required String taskId,
    required bool approved,
    String? comment,
  }) async {
    try {
      isSubmittingFeedback.value = true;

      bool wasItPaid = await billWasPaid(taskId);

      if (!wasItPaid) {
        throw Exception(
          'Solo se puede enviar feedback si has pagado tu factura',
        );
      }

      // 1) Verificar que la tarea existe y puede recibir feedback
      final task = selectedTask.value;
      if (task == null) throw Exception('No hay tarea seleccionada');

      if (task.status != 'completed') {
        throw Exception(
          'Solo se puede enviar feedback para tareas completadas',
        );
      }

      if (task.clientFeedback != null) {
        throw Exception('La tarea ya tiene feedback y no puede ser modificada');
      }

      // 2) Guardar estado anterior para rollback
      final oldTaskState = TaskEntity(
        taskID: task.taskID,
        title: task.title,
        description: task.description,
        status: task.status,
        assignedEmployeeID: task.assignedEmployeeID,
        assignedEmployeeName: task.assignedEmployeeName,
        clientID: task.clientID,
        clientName: task.clientName,
        createdAt: task.createdAt,
        completedAt: task.completedAt,
        clientFeedback: task.clientFeedback,
        materialsUsed: List.from(task.materialsUsed),
        comment: task.comment,
        photoEmployeeData: task.photoEmployeeData,
      );

      // 3) Actualizar feedback en la tarea
      await _taskRepository.updateTaskFeedback(
        taskId: taskId,
        approved: approved,
        comment: comment,
      );

      // 4) Crear notificación
      try {
        final notification = NotificationEntity(
          notificationID: _generateNotificationId(),
          title: 'Tarea Calificada',
          body:
              'La tarea $taskId ha sido ${approved ? 'APROBADA' : 'RECHAZADA'} por el cliente${comment != null ? ' con comentarios' : ''}',
          type: 'task_rated',
          read: false,
          createdAt: DateTime.now(),
        );

        await _notificationRepository.createNotification(notification);
      } catch (notificationError) {
        // 5) Si falla la notificación, revertir el feedback
        try {
          await _revertTaskFeedback(taskId, oldTaskState);
        } catch (rollbackError) {
          throw Exception(
            'Error crítico: No se pudo crear notificación ni revertir cambios. '
            'Notificación: $notificationError, Rollback: $rollbackError',
          );
        }
        throw Exception(
          'No se pudo crear la notificación. Los cambios fueron revertidos.',
        );
      }

      // 6) Actualizar la tarea localmente
      await searchTaskById(taskId);

      // 7) Limpiar comentario temporal
      tempComment.value = '';

      Get.snackbar(
        'Éxito',
        'Feedback enviado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar el feedback: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Recargar la tarea para tener estado actualizado
      if (selectedTask.value != null) {
        await searchTaskById(selectedTask.value!.taskID);
      }
    } finally {
      isSubmittingFeedback.value = false;
    }
  }

  Future<bool> billWasPaid(String taskId) async {
    final List<InvoiceEntity> invoices = await _invoiceRepository
        .getInvoicesOnce();

    final wasItPaid = invoices.any(
      (element) => element.taskID == taskId && element.status == "paid",
    );
    return wasItPaid;
  }

  /// Método para revertir el feedback de una tarea
  Future<void> _revertTaskFeedback(
    String taskId,
    TaskEntity oldTaskState,
  ) async {
    try {
      // Necesitamos un método en el repositorio para revertir el feedback
      // Por ahora, recargamos la tarea original
      await searchTaskById(taskId);

      // Mostrar mensaje informativo
      Get.snackbar(
        'Información',
        'Los cambios fueron revertidos debido a un error en el sistema',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      throw Exception('Error al revertir cambios: $e');
    }
  }

  void updateTempComment(String comment) {
    tempComment.value = comment;
  }

  void clearSearch() {
    selectedTask.value = null;
    searchError.value = '';
    tempComment.value = '';
  }

  String _generateNotificationId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}';
  }
}
