// lib/domain/entities/audit_log_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogEntity {
  final String auditLogID;
  final String action;
  final String actorID;
  final String target;
  final DateTime timestamp;

  AuditLogEntity({
    required this.auditLogID,
    required this.action,
    required this.actorID,
    required this.target,
    required this.timestamp,
  });

  factory AuditLogEntity.fromFirestore(Map<String, dynamic> data) {
    return AuditLogEntity(
      auditLogID: data['auditLogID'] ?? '',
      action: data['action'] ?? '',
      actorID: data['actorID'] ?? '',
      target: data['target'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auditLogID': auditLogID,
      'action': action,
      'actorID': actorID,
      'target': target,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}