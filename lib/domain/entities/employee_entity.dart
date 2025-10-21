// lib/domain/entities/employee_entity.dart
import 'package:check_job/domain/entities/task_entity/task_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class EmployeeEntity {
  final String employeesID;
  final String name;
  final String email;
  final String phone;
  final bool? isActive;
  final DateTime createdAt;
  final List<TaskEntity>? tasks;
  final Uint8List? photoData;

  EmployeeEntity({
    required this.employeesID,
    required this.name,
    required this.email,
    required this.phone,
    this.isActive,
    required this.createdAt,
    this.tasks,
    this.photoData,
  });

  factory EmployeeEntity.fromFirestore(Map<String, dynamic> data) {
    return EmployeeEntity(
      employeesID: data['employeesID'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeesID': employeesID,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EmployeeEntity copyWith({
    String? employeesID,
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    List<TaskEntity>? tasks,
    Uint8List? photoData,
  }) {
    return EmployeeEntity(
      employeesID: employeesID ?? this.employeesID,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
      photoData: photoData ?? this.photoData,
    );
  }

  bool calculateIsActive() {
    if (tasks == null || tasks!.isEmpty) return false;
    return tasks!.any((task) =>  task.status != 'completed');
  }

  List<TaskEntity> get completedTasks {
    return tasks?.where((task) => task.status == 'completed').toList() ?? [];
  }

  List<TaskEntity> get inProgressTasks {
    return tasks?.where((task) => task.status != 'completed').toList() ?? [];
  }
}