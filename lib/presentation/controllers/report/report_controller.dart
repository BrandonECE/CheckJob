// lib/presentation/controllers/report/report_controller.dart
import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:get/get.dart';
import 'dart:async';
import 'package:check_job/domain/entities/report_entity.dart';
import 'package:check_job/domain/repositories/report_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';
// Necesitas agregar estas importaciones al inicio del archivo:
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class ReportController extends GetxController {
  final ReportRepository _reportRepository;
  final AdminController _adminController;

  ReportController({
    required ReportRepository reportRepository,
    required AdminController adminController,
  })  : _reportRepository = reportRepository,
        _adminController = adminController;

  // Estados observables
  final reports = <ReportEntity>[].obs;
  final isLoading = false.obs;
  final selectedReportType = ReportType.tasks.obs;
  final selectedDateRange = Rxn<DateTimeRangeEntity>();
  final generatingReport = false.obs;
  final currentProgress = 0.0.obs;
  final savedReports = <ReportEntity>[].obs;

  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    loadSavedReports();
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    generatingReport.value = false;
    currentProgress.value = 0.0;
    super.onClose();
  }

  /// Genera el reporte con rollback y log de auditoría
  Future<ReportEntity> generateReport({
    required ReportType type,
    required DateTimeRangeEntity dateRange,
    Map<String, dynamic>? additionalFilters,
  }) async {
    try {
      generatingReport.value = true;
      currentProgress.value = 0.0;
      _startSimulateProgress();

      // 1) Generar el reporte (heavy I/O)
      final report = await _reportRepository.generateReport(
        type: type,
        dateRange: dateRange,
        additionalFilters: additionalFilters,
      );

      // 2) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'report_generated',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: report.titleForUI,
        );
      } catch (auditError) {
        // 3) Si falla el audit, revertir (eliminar reporte creado)
        try {
          await _reportRepository.deleteSavedReport(report.reportId);
          // También eliminar archivo local si existe
          try {
            final directory = await getApplicationDocumentsDirectory();
            final reportsDir = Directory('${directory.path}/reports');
            if (await reportsDir.exists()) {
              final files = reportsDir.listSync();
              for (final f in files) {
                if (f is File && f.uri.pathSegments.last.contains(report.reportId)) {
                  await f.delete();
                }
              }
            }
          } catch (_) {}
        } catch (rollbackError) {
          _showError(
            'Error crítico: No se pudo registrar la acción ni revertir la generación.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se revirtió la generación.');
      }

      // Insertar en listas solo si todo fue exitoso
      reports.insert(0, report);
      final exists = savedReports.any((r) => r.reportId == report.reportId);
      if (!exists) {
        savedReports.insert(0, report);
      }

      // Completar progreso
      await _completeProgressAndCancelTimer();

      _showSuccess('Reporte generado correctamente');

      return report;
    } catch (e) {
      _progressTimer?.cancel();
      _progressTimer = null;
      generatingReport.value = false;
      await Future.delayed(const Duration(milliseconds: 300));
      currentProgress.value = 0.0;
      _showError('Error al generar el reporte: ${e.toString()}');
      return Future.error(e);
    } finally {
      _progressTimer?.cancel();
      _progressTimer = null;
      generatingReport.value = false;
      await Future.delayed(const Duration(milliseconds: 300));
      currentProgress.value = 0.0;
    }
  }

  // ========== OPERACIONES CON ROLLBACK ==========
  Future<void> downloadReport(ReportEntity report) async {
    try {
      await _reportRepository.downloadReport(report);
    } catch (e) {
      _showError('No se pudo descargar el reporte: ${e.toString()}');
      return Future.error(e);
    }
  }

  Future<void> shareReport(ReportEntity report) async {
    try {
      await _reportRepository.shareReport(report);
    } catch (e) {
      _showError('No se pudo compartir el reporte: ${e.toString()}');
      return Future.error(e);
    }
  }

  Future<void> saveReportToDevice(ReportEntity report) async {
    try {
      await _reportRepository.saveReportToDevice(report);
    } catch (e) {
      _showError('No se pudo guardar el reporte: ${e.toString()}');
      return Future.error(e);
    }
  }

  Future<void> deleteReport(ReportEntity report) async {
    isLoading.value = true;
    try {
      // 1) Guardar snapshot del reporte para posible rollback
      final reportToDelete = report;
      
      // 2) Eliminar el reporte
      await _reportRepository.deleteSavedReport(report.reportId);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'report_deleted',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: report.titleForUI,
        );
      } catch (auditError) {
        // 4) Si falla audit, restaurar el reporte
        try {
          await _reportRepository.saveReportToFirestore(reportToDelete);
          // También restaurar archivo local si es necesario
          if (reportToDelete.fileData != null) {
            await _reportRepository.saveReportLocally(reportToDelete, reportToDelete.fileData!);
          }
        } catch (rollbackError) {
          _showError(
            'Error crítico: No se pudo registrar la acción ni restaurar el reporte.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se restauró el reporte eliminado.');
      }

      // Remover de las listas solo si todo fue exitoso
      reports.removeWhere((r) => r.reportId == report.reportId);
      savedReports.removeWhere((r) => r.reportId == report.reportId);

      _showSuccess('Reporte eliminado correctamente');
    } catch (e) {
      _showError('No se pudo eliminar el reporte: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== MÉTODOS EXISTENTES ==========
  void startBackgroundDownload(ReportEntity report) {
    Future(() async {
      try {
        await downloadReport(report);
      } catch (_) {}
    });
  }

  DateTimeRangeEntity getCurrentMonthRange() =>
      _reportRepository.getCurrentMonthRange();
  DateTimeRangeEntity getLastMonthRange() =>
      _reportRepository.getLastMonthRange();
  DateTimeRangeEntity getLastWeekRange() =>
      _reportRepository.getLastWeekRange();
  DateTimeRangeEntity getCustomRange(DateTime start, DateTime end) =>
      _reportRepository.getCustomRange(start, end);

  DateTimeRangeEntity getDateRangeForOption(DateRangeOption option) {
    switch (option) {
      case DateRangeOption.currentMonth:
        return getCurrentMonthRange();
      case DateRangeOption.lastMonth:
        return getLastMonthRange();
      case DateRangeOption.lastWeek:
        return getLastWeekRange();
      case DateRangeOption.custom:
        return getCurrentMonthRange();
    }
  }

  String getDateRangeDisplay(DateRangeOption option) {
    final r = getDateRangeForOption(option);
    return r.formattedForDisplay;
  }

  Future<void> loadSavedReports() async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 300));
      final saved = await _reportRepository.getSavedReports();
      savedReports.value = saved;
    } catch (e) {
      _showError(
        'No se pudieron cargar los reportes guardados: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== PROGRESO SIMULADO ==========
  void _startSimulateProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;

    const totalSteps = 20;
    var currentStep = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      currentStep++;
      final simulated = (currentStep / totalSteps) * 0.9;
      currentProgress.value = simulated.clamp(0.0, 0.9);
      if (currentStep >= totalSteps) {
        timer.cancel();
        _progressTimer = null;
      }
    });
  }

  Future<void> _completeProgressAndCancelTimer() async {
    try {
      _progressTimer?.cancel();
      _progressTimer = null;
    } catch (_) {}
    currentProgress.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 250));
  }

  // ========== SNACKBARS ==========
  void _showSuccess(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // ========== UTIL ==========
  void clearReports() => reports.clear();
  void removeReport(ReportEntity report) => reports.remove(report);

  List<ReportEntity> getReportsByType(ReportType type) =>
      reports.where((r) => r.type == type.firestoreValue).toList();

  ReportFormat getRecommendedFormat(ReportType type) =>
      _reportRepository.getRecommendedFormatForType(type);
}

