import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCommentEntity {
  final String taskID;
  final String text;
  final Timestamp createdAt;

  TaskCommentEntity({
    required this.taskID,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskID': taskID,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory TaskCommentEntity.fromMap(Map<String, dynamic> map) {
    return TaskCommentEntity(
      taskID: map['taskID'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Ejemplo para testing
  static TaskCommentEntity get example {
    return TaskCommentEntity(
      taskID: 'task_001',
      text: 'Tarea completada satisfactoriamente. Cliente muy satisfecho.',
      createdAt: Timestamp.now(),
    );
  }
}