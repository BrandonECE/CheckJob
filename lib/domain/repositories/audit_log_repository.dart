// lib/domain/repositories/audit_log_repository.dart
import 'package:check_job/domain/entities/audit_log_entity.dart';

abstract class AuditLogRepository {
  Future<void> logAction({
    required String action,
    required String actorID,
    required String target,
  });

  Stream<List<AuditLogEntity>> getAuditLogs();
  Future<List<AuditLogEntity>> getAuditLogsOnce();
}