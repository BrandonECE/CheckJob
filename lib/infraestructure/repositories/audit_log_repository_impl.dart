// lib/data/repositories/audit_log_repository_impl.dart
import 'package:check_job/domain/repositories/audit_log_repository.dart';
import 'package:check_job/domain/services/audit_log_service.dart';
import 'package:check_job/domain/entities/audit_log_entity.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogService _auditLogService;

  AuditLogRepositoryImpl({required AuditLogService auditLogService})
      : _auditLogService = auditLogService;

  @override
  Future<void> logAction({
    required String action,
    required String actorID,
    required String target,
  }) async {
    try {
      return await _auditLogService.logAction(
        action: action,
        actorID: actorID,
        target: target,
      );
    } catch (e) {
      return Future.error('Error en repositorio al registrar acción: $e');
    }
  }

  @override
  Stream<List<AuditLogEntity>> getAuditLogs() {
    try {
      return _auditLogService.getAuditLogs();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener logs: $e');
    }
  }

  @override
  Future<List<AuditLogEntity>> getAuditLogsOnce() {
    try {
      return _auditLogService.getAuditLogsOnce();
    } catch (e) {
      return Future.error('Error en repositorio al obtener logs una vez: $e');
    }
  }
}