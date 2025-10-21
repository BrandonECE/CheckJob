import 'dart:typed_data';

import 'package:check_job/domain/entities/enities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskEntity {
  final String taskID;
  final String title;
  final String description;
  final String status;
  final String assignedEmployeeID;
  final String assignedEmployeeName;
  final String clientID;
  final String clientName;
  final Timestamp createdAt;
  final Timestamp? completedAt;
  final TaskClientFeedbackEntity? clientFeedback;
  final List<TaskMaterialUsedEntity> materialsUsed;
  final TaskCommentEntity? comment; // Comentario principal de la tarea
  Uint8List? photoEmployeeData;

  TaskEntity({
    required this.taskID,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedEmployeeID,
    required this.assignedEmployeeName,
    required this.clientID,
    required this.clientName,
    required this.createdAt,
    this.completedAt,
    this.clientFeedback,
    required this.materialsUsed,
    this.comment,
    this.photoEmployeeData,
  });

  void setPhoto(Uint8List bytes) {
    photoEmployeeData = bytes;
  }

  /// Limpia la imagen (la deja nula).
  void clearPhoto() {
    photoEmployeeData = null;
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'taskID': taskID,
      'title': title,
      'description': description,
      'status': status,
      'assignedEmployeeName': assignedEmployeeName,
      'assignedEmployeeID': assignedEmployeeID,
      'clientName': clientName,
      'clientID': clientID,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'clientFeedback': clientFeedback?.toMap(),
      'materialsUsed': materialsUsed
          .map((material) => material.toMap())
          .toList(),
    };
  }

  // Crear desde Map de Firestore
  factory TaskEntity.fromMap(Map<String, dynamic> map) {
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
      clientFeedback: map['clientFeedback'] != null
          ? TaskClientFeedbackEntity.fromMap(
              Map<String, dynamic>.from(map['clientFeedback']),
            )
          : null,
      materialsUsed: List<TaskMaterialUsedEntity>.from(
        (map['materialsUsed'] ?? []).map(
          (material) => TaskMaterialUsedEntity.fromMap(material),
        ),
      ),
    );
  }

  // Ejemplo para testing
  static TaskEntity get example {
    return TaskEntity(
      taskID: 'task_001',
      title: 'Mantenimiento Preventivo Completo',
      description:
          'Cambio de aceite sintético, filtros de aire y aceite, revisión de frenos y sistema eléctrico',
      status: 'completed',
      assignedEmployeeID: 'emp_001',
      assignedEmployeeName: 'Juan Manuel',
      clientID: 'cli_001',
      clientName: 'Pedro Pascal',
      createdAt: Timestamp.now(),
      completedAt: Timestamp.now(),
      clientFeedback: TaskClientFeedbackEntity(
        approved: null,
        submittedAt: Timestamp.now(),
      ),
      materialsUsed: [
        TaskMaterialUsedEntity(
          materialID: 'mat_001',
          materialName: "Aceite",
          quantity: 4,
          unit: 'Lts',
        ),
        TaskMaterialUsedEntity(
          materialName: "Tornillos",
          materialID: 'mat_002',
          quantity: 1,
          unit: 'Pzas',
        ),
        TaskMaterialUsedEntity(
          materialID: 'mat_004',
          materialName: 'Placas',
          quantity: 4,
          unit: 'Pzas',
        ),
      ],
      comment: TaskCommentEntity(
        taskID: 'task_001',
        text: 'Tarea completada satisfactoriamente. Cliente muy satisfecho.',
        createdAt: Timestamp.now(),
      ),
    );
  }
}


