// lib/presentation/controllers/audit_log_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:check_job/domain/entities/audit_log_entity.dart';
import 'package:check_job/domain/repositories/audit_log_repository.dart';

class AuditLogController extends GetxController {
  final AuditLogRepository _auditLogRepository;
  StreamSubscription? _auditLogsSubscription;

  AuditLogController({required AuditLogRepository auditLogRepository})
      : _auditLogRepository = auditLogRepository;

  final RxList<AuditLogEntity> auditLogs = <AuditLogEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    _loadAuditLogs();
    super.onInit();
  }

  @override
  void onClose() {
    _auditLogsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadAuditLogs() async{
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _auditLogsSubscription = _auditLogRepository.getAuditLogs().listen((logs) {
      auditLogs.assignAll(logs);
      isLoading.value = false;
    });
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<AuditLogEntity> get filteredLogs {
    if (searchQuery.isEmpty) return auditLogs;
    return auditLogs.where((log) {
      return log.action.toLowerCase().contains(searchQuery.toLowerCase()) ||
          log.actorID.toLowerCase().contains(searchQuery.toLowerCase()) ||
          log.target.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Método para registrar una acción desde otros controladores
  static Future<void> logAction({
    required String action,
    required String actorID,
    required String target,
  }) async {
    try {
      final AuditLogRepository repo = Get.find<AuditLogRepository>();
      await repo.logAction(action: action, actorID: actorID, target: target);
    } catch (e) {
      // Si no se ha inyectado el repositorio, no hacemos nada o logueamos el error
      return Future.error('Error en servicio al registrar acción: $e');
    }
  }
}