// lib/presentation/controllers/admin_panel/admin_panel_controller.dart
import 'dart:async';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:get/get.dart';

class AdminPanelController extends GetxController {
  final TaskRepository _taskRepository;

  StreamSubscription? _tasksSubscription;

  AdminPanelController({required TaskRepository taskRepository})
    : _taskRepository = taskRepository;

  // Estados de carga
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Contadores para las estadísticas rápidas
  final RxInt pendingTasksCount = 0.obs;
  final RxInt inProgressTasksCount = 0.obs;
  final RxInt completedTasksCount = 0.obs;

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

  Future<void> _loadTasks() async {
    isLoading.value = true;
    error.value = '';

    await Future.delayed(Duration(milliseconds: 600));

    try {
      _tasksSubscription = _taskRepository.getTasks().listen(
        (tasks) {
          _calculateTaskStats(tasks);
          isLoading.value = false;
        },
        onError: (err) {
          error.value = 'Error al cargar tareas: $err';
          isLoading.value = false;
          // Establecer valores por defecto en caso de error
          pendingTasksCount.value = 0;
          inProgressTasksCount.value = 0;
          completedTasksCount.value = 0;
        },
      );
    } catch (e) {
      error.value = 'Error inicial: $e';
      isLoading.value = false;
      pendingTasksCount.value = 0;
      inProgressTasksCount.value = 0;
      completedTasksCount.value = 0;
    }
  }

  void _calculateTaskStats(List<TaskEntity> tasks) {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (final task in tasks) {
      final status = task.status.toLowerCase();

      if (status.contains('pending')) {
        pending++;
      } else if (status.contains('in_progress') ||
          status.contains('progress')) {
        inProgress++;
      } else if (status.contains('completed')) {
        completed++;
      }
    }

    pendingTasksCount.value = pending;
    inProgressTasksCount.value = inProgress;
    completedTasksCount.value = completed;
  }

  Future<void> refreshStats() async {
    isLoading.value = true;
    error.value = '';

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final tasks = await _taskRepository.getTasksOnce();
      _calculateTaskStats(tasks);
    } catch (e) {
      error.value = 'Error al actualizar: $e';
      // En caso de error, mantener los valores anteriores
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obtener los contadores actuales
  Map<String, int> getQuickStats() {
    return {
      'pending': pendingTasksCount.value,
      'inProgress': inProgressTasksCount.value,
      'completed': completedTasksCount.value,
    };
  }
}
