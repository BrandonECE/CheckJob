import 'package:check_job/domain/entities/enities.dart';

abstract class TaskService  {
  Future<TaskEntity?> getTaskById(String taskId);
  Future<void> updateTaskFeedback({
    required String taskId,
    required bool approved,
    String? comment,
  });
  Future<void> revertTaskFeedback(String taskId); // Nuevo método para rollback
  Stream<List<TaskEntity>> getTasks();
  Future<List<TaskEntity>> getTasksOnce();

  Future<bool> checkTaskIdExists(String taskId);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<void> updateTaskStatus(String taskId, String newStatus);
}