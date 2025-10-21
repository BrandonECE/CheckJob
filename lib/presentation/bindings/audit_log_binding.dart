// lib/presentation/bindings/audit_log_binding.dart
import 'package:check_job/infraestructure/repositories/audit_log_repository_impl.dart';
import 'package:check_job/infraestructure/services/audit_log_service_impl.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/audit_log_service.dart';
import 'package:check_job/domain/repositories/audit_log_repository.dart';

class AuditLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuditLogService>(() => AuditLogServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<AuditLogRepository>(() => AuditLogRepositoryImpl(
          auditLogService: Get.find<AuditLogService>(),
        ));
    Get.lazyPut<AuditLogController>(() => AuditLogController(
          auditLogRepository: Get.find<AuditLogRepository>(),
        ));
  }
}