// lib/data/services/audit_log_service_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/audit_log_service.dart';
import 'package:check_job/domain/entities/audit_log_entity.dart';

class AuditLogServiceImpl implements AuditLogService {
  final FirebaseFirestore _firestore;

  AuditLogServiceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> logAction({
    required String action,
    required String actorID,
    required String target,
  }) async {
    try {
      final log = AuditLogEntity(
        auditLogID: _generateLogId(),
        action: action,
        actorID: actorID,
        target: target,
        timestamp: DateTime.now(),
      );

      // Guardar en la subcolección: settings/app_config/audit_logs
      await _firestore
          .collection('settings')
          .doc('app_config')
          .collection('audit_logs')
          .doc(log.auditLogID)
          .set(log.toMap());
    } catch (e) {
      return Future.error('Error en servicio al registrar acción: $e');
    }
  }

  @override
  Stream<List<AuditLogEntity>> getAuditLogs() {
    try {
      return _firestore
          .collection('settings')
          .doc('app_config')
          .collection('audit_logs')
          .orderBy('timestamp', descending: true) // Ordenar por fecha descendente
          .snapshots()
          .handleError((error) {
            throw 'Error en servicio al obtener stream de logs: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => AuditLogEntity.fromFirestore(doc.data()))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error en servicio al crear stream: $e');
    }
  }

  @override
  Future<List<AuditLogEntity>> getAuditLogsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('settings')
          .doc('app_config')
          .collection('audit_logs')
          .orderBy('timestamp', descending: true) // Ordenar por fecha descendente
          .get(GetOptions(source: Source.server));
      
      return snapshot.docs
          .map((doc) => AuditLogEntity.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      return Future.error('Error en servicio al obtener logs: $e');
    }
  }

  String _generateLogId() {
    return 'log_${DateTime.now().millisecondsSinceEpoch}';
  }
}