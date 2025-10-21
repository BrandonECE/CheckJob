import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/task_service.dart';

import '../../domain/entities/enities.dart';

class TaskServiceImpl implements TaskService {
  final FirebaseFirestore _firestore;

  TaskServiceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<TaskEntity?> getTaskById(String taskId) async {
    try {
      final docRef = _firestore.collection('tasks').doc(taskId);
      final doc = await docRef.get(GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final map = doc.data()!;

        // 1) Intentar leer el comentario más reciente desde la subcolección 'task_comments'
        TaskCommentEntity? commentFromSub;
        try {
          final commentQuery = await docRef
              .collection('task_comments')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get(GetOptions(source: Source.server));

          if (commentQuery.docs.isNotEmpty) {
            final commentMap = Map<String, dynamic>.from(commentQuery.docs.first.data());
            commentFromSub = TaskCommentEntity.fromMap(commentMap);
          }
        } catch (_) {
          commentFromSub = null;
        }

        // 2) Construir la lista de materiales
        final materialsList = List<TaskMaterialUsedEntity>.from(
          (map['materialsUsed'] ?? []).map(
            (material) => TaskMaterialUsedEntity.fromMap(Map<String, dynamic>.from(material)),
          ),
        );

        // 3) Construir clientFeedback (si existe)
        final TaskClientFeedbackEntity? clientFeedback = map['clientFeedback'] != null
            ? TaskClientFeedbackEntity.fromMap(Map<String, dynamic>.from(map['clientFeedback']))
            : null;

        // 4) Construir TaskEntity
        final task = TaskEntity(
          taskID: map['taskID'] ?? '',
          title: map['title'] ?? '',
          description: map['description'] ?? '',
          status: map['status'] ?? 'pending',
          assignedEmployeeName: map['assignedEmployeeName'] ?? '',
          clientName: map['clientName'] ?? '',
          assignedEmployeeID: map['assignedEmployeeID'] ?? '',
          clientID: map['clientID'] ?? '',
          createdAt: map['createdAt'] ?? Timestamp.now(),
          completedAt: map['completedAt'],
          clientFeedback: clientFeedback,
          materialsUsed: materialsList,
          comment: commentFromSub,
        );

        return task;
      }

      return null;
    } catch (e) {
      throw Exception('Error al obtener tarea: $e');
    }
  }

  @override
  Future<void> updateTaskFeedback({
    required String taskId,
    required bool approved,
    String? comment,
  }) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(taskId);
      
      // Verificamos que la tarea existe
      final taskDoc = await taskRef.get(GetOptions(source: Source.server));
      if (!taskDoc.exists) {
        throw Exception('Tarea no encontrada');
      }

      // Verificamos que no tenga feedback previo
      final taskData = taskDoc.data()!;
      if (taskData['clientFeedback'] != null) {
        throw Exception('La tarea ya tiene feedback y no puede ser modificada');
      }

      // 1) Actualizamos el feedback (sin comentario aquí)
      await taskRef.update({
        'clientFeedback': {
          'approved': approved,
          'submittedAt': Timestamp.now(),
        }
      });

      // 2) Si hay comentario, lo guardamos en la subcolección task_comments
      if (comment != null && comment.isNotEmpty) {
        final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
        await taskRef.collection('task_comments').doc(commentId).set({
          'taskID': taskId,
          'text': comment,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Error al actualizar feedback: $e');
    }
  }

  @override
  Future<void> revertTaskFeedback(String taskId) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(taskId);
      
      // 1) Remover el feedback del documento principal
      await taskRef.update({
        'clientFeedback': FieldValue.delete(),
      });

      // 2) Remover el comentario más reciente de la subcolección (si existe)
      try {
        final commentsQuery = await taskRef
            .collection('task_comments')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get(GetOptions(source: Source.server));

        if (commentsQuery.docs.isNotEmpty) {
          await taskRef
              .collection('task_comments')
              .doc(commentsQuery.docs.first.id)
              .delete();
        }
      } catch (e) {
        // Si falla eliminar el comentario, continuamos
        print('Error eliminando comentario durante rollback: $e');
      }
    } catch (e) {
      throw Exception('Error al revertir feedback: $e');
    }
  }


 @override
  Stream<List<TaskEntity>> getTasks() {
    try {
      return _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener tareas: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => _mapDocumentToTaskEntity(doc))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error al crear stream de tareas: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasksOnce() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((doc) => _mapDocumentToTaskEntity(doc))
          .toList();
    } catch (e) {
      return Future.error('Error al obtener tareas: $e');
    }
  }

  // Helper para mapear documentos a TaskEntity
  TaskEntity _mapDocumentToTaskEntity(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    
    // Construir la lista de materiales
    final materialsList = List<TaskMaterialUsedEntity>.from(
      (map['materialsUsed'] ?? []).map(
        (material) => TaskMaterialUsedEntity.fromMap(Map<String, dynamic>.from(material)),
      ),
    );

    // Construir clientFeedback (si existe)
    final TaskClientFeedbackEntity? clientFeedback = map['clientFeedback'] != null
        ? TaskClientFeedbackEntity.fromMap(Map<String, dynamic>.from(map['clientFeedback']))
        : null;

    return TaskEntity(
      taskID: map['taskID'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      assignedEmployeeName: map['assignedEmployeeName'] ?? '',
      clientName: map['clientName'] ?? '',
      assignedEmployeeID: map['assignedEmployeeID'] ?? '',
      clientID: map['clientID'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      completedAt: map['completedAt'],
      clientFeedback: clientFeedback,
      materialsUsed: materialsList,
      comment: null, // Para el dashboard no necesitamos los comentarios
    );
  }

  @override
  Future<bool> checkTaskIdExists(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get(GetOptions(source: Source.server));
      return doc.exists;
    } catch (e) {
      throw Exception('Error al verificar ID de tarea: $e');
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    try {
      // Convertir la tarea a un mapa, asegurando que los materiales se conviertan correctamente
      final taskMap = _taskEntityToMap(task);
      await _firestore.collection('tasks').doc(task.taskID).set(taskMap);
    } catch (e) {
      throw Exception('Error al crear tarea: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskMap = _taskEntityToMap(task);
      await _firestore.collection('tasks').doc(task.taskID).update(taskMap);
    } catch (e) {
      throw Exception('Error al actualizar tarea: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado de tarea: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Error al eliminar tarea: $e');
    }
  }

  // Helper para convertir TaskEntity a Map
  Map<String, dynamic> _taskEntityToMap(TaskEntity task) {
    return {
      'taskID': task.taskID,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'assignedEmployeeName': task.assignedEmployeeName,
      'clientName': task.clientName,
      'assignedEmployeeID': task.assignedEmployeeID,
      'clientID': task.clientID,
      'createdAt': task.createdAt,
      'completedAt': task.completedAt,
      'clientFeedback': task.clientFeedback != null ? {
        'approved': task.clientFeedback!.approved,
        'submittedAt': task.clientFeedback!.submittedAt,
      } : null,
      'materialsUsed': task.materialsUsed.map((material) => {
        'materialName': material.materialName,
        'quantity': material.quantity,
        'unit': material.unit,
      }).toList(),
    };
  }


}