import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/services/task_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskService _taskService;

  TaskRepositoryImpl({required TaskService taskService})
      : _taskService = taskService;

  @override
  Future<TaskEntity?> getTaskById(String taskId) async {
    try {
      return await _taskService.getTaskById(taskId);
    } catch (e) {
      throw Exception('Error en repositorio al obtener tarea: $e');
    }
  }

  @override
  Future<void> updateTaskFeedback({
    required String taskId,
    required bool approved,
    String? comment,
  }) async {
    try {
      return await _taskService.updateTaskFeedback(
        taskId: taskId,
        approved: approved,
        comment: comment,
      );
    } catch (e) {
      throw Exception('Error en repositorio al actualizar feedback: $e');
    }
  }

  @override
  Future<void> revertTaskFeedback(String taskId) async {
    try {
      return await _taskService.revertTaskFeedback(taskId);
    } catch (e) {
      throw Exception('Error en repositorio al revertir feedback: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getTasks() {
    try {
      return _taskService.getTasks();
    } catch (e) {
      throw Exception('Error en repositorio al obtener tareas: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasksOnce() async {
    try {
      return await _taskService.getTasksOnce();
    } catch (e) {
      throw Exception('Error en repositorio al obtener tareas: $e');
    }
  }

 @override
  Future<bool> checkTaskIdExists(String taskId) async {
    try {
      return await _taskService.checkTaskIdExists(taskId);
    } catch (e) {
      throw Exception('Error en repositorio al verificar ID: $e');
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    try {
      return await _taskService.createTask(task);
    } catch (e) {
      throw Exception('Error en repositorio al crear tarea: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      return await _taskService.updateTask(task);
    } catch (e) {
      throw Exception('Error en repositorio al actualizar tarea: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      return await _taskService.updateTaskStatus(taskId, newStatus);
    } catch (e) {
      throw Exception('Error en repositorio al actualizar estado: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      return await _taskService.deleteTask(taskId);
    } catch (e) {
      throw Exception('Error en repositorio al eliminar tarea: $e');
    }
  }
}