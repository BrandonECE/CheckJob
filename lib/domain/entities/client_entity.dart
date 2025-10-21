// lib/domain/entities/client_entity.dart
import 'package:check_job/domain/entities/enities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientEntity {
  final String clientID;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final bool? isActive; // Nuevo campo no requerido
  final List<TaskEntity>? tasks; // Nuevo campo no requerido

  ClientEntity({
    required this.clientID,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.isActive,
    this.tasks,
  });

  factory ClientEntity.fromFirestore(Map<String, dynamic> data) {
    return ClientEntity(
      clientID: data['clientID'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientID': clientID,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    // Nota: 'tasks' no se incluye en toMap porque es una relación, no se almacena directamente
  }

  ClientEntity copyWith({
    String? clientID,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    List<TaskEntity>? tasks,
  }) {
    return ClientEntity(
      clientID: clientID ?? this.clientID,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      tasks: tasks ?? this.tasks,
    );
  }

  // Método helper para calcular si el cliente está activo
  bool calculateIsActive() {
    if (tasks == null || tasks!.isEmpty) return false;
    
    // Un cliente está activo si tiene al menos una tarea 
    // que esté en progreso Y no tenga feedback del cliente
    return tasks!.any((task) => 
      task.clientFeedback == null
    );
  }

  // Método para obtener tareas completadas
  List<TaskEntity> get completedTasks {
    return tasks?.where((task) => task.status == 'completed' && task.clientFeedback != null).toList() ?? [];
  }

  // Método para obtener tareas en progreso
  List<TaskEntity> get inProgressTasks {
    return tasks?.where((task) =>  task.clientFeedback == null
    ).toList() ?? [];
  }
}