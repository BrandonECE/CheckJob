// lib/domain/entities/admin_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final String adminID;
  final String name;
  final String email;
  final DateTime createdAt;

  AdminEntity({
    required this.adminID,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory AdminEntity.fromFirestore(Map<String, dynamic> data) {
    return AdminEntity(
      adminID: data['adminID'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminID': adminID,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}