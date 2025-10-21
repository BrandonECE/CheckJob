// lib/infraestructure/repositories/report_repository_impl.dart
import 'dart:typed_data';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:check_job/domain/repositories/report_repository.dart';
import 'package:check_job/domain/services/report_service.dart';
import 'package:check_job/domain/entities/report_entity.dart';

class ReportRepositoryImpl extends ReportRepository {
  final ReportService _reportService;

  ReportRepositoryImpl({required ReportService reportService})
    : _reportService = reportService;

  @override
  Future<ReportEntity> generateReport({
    required ReportType type,
    required DateTimeRangeEntity dateRange,
    Map<String, dynamic>? additionalFilters,
  }) async {
    try {
      final format = _reportService.getRecommendedFormatForType(type);
      final report = await _reportService.generateReport(
        type: type,
        dateRange: dateRange,
        format: format,
        additionalFilters: additionalFilters,
      );
      return report;
    } catch (e) {
      print('Repository.generateReport error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> downloadReport(ReportEntity report) async {
    try {
      final data = await _reportService.getReportData(report);

      final ext = (report.format == ReportFormat.csv) ? 'csv' : 'pdf';

      if (report.format == ReportFormat.pdf) {
        await Printing.layoutPdf(onLayout: (_) => data);
      } else {
        // CSV -> solicitar ruta al usuario y guardar
        final String? outputFile = await FilePicker.platform.saveFile(
          bytes: data,
          fileName: '${report.reportId}.$ext',
          dialogTitle: 'Guardar Reporte',
        );
        if (outputFile != null) {
          final f = File(outputFile);
          await f.writeAsBytes(data, flush: true);
        }
      }
    } catch (e) {
      print('Repository.downloadReport error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> shareReport(ReportEntity report) async {
    try {
      final data = await _reportService.getReportData(report);
      final directory = await getTemporaryDirectory();
      final fileName =
          '${report.reportId}.${report.format == ReportFormat.csv ? 'csv' : 'pdf'}';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(data, flush: true);
      await Share.shareXFiles([
        XFile(file.path, name: fileName),
      ], subject: 'Reporte CheckJob');
    } catch (e) {
      print('Repository.shareReport error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> saveReportToDevice(ReportEntity report) async {
    try {
      final data = await _reportService.getReportData(report);
      final String? outputFile = await FilePicker.platform.saveFile(
        bytes: data,
        fileName:
            '${report.reportId}.${report.format == ReportFormat.csv ? 'csv' : 'pdf'}',
        dialogTitle: 'Guardar Reporte',
      );
      if (outputFile != null) {
        final f = File(outputFile);
        await f.writeAsBytes(data, flush: true);
      }
    } catch (e) {
      print('Repository.saveReportToDevice error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<List<ReportEntity>> getSavedReports() async {
    try {
      return await _reportService.getSavedReports();
    } catch (e) {
      print('Repository.getSavedReports error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteSavedReport(String reportId) async {
    try {
      await _reportService.deleteSavedReport(reportId);
      return;
    } catch (e) {
      print('Repository.deleteSavedReport error: $e');
      return Future.error(e);
    }
  }

  @override
  ReportFormat getRecommendedFormatForType(ReportType type) {
    return _reportService.getRecommendedFormatForType(type);
  }

  @override
  DateTimeRangeEntity getCurrentMonthRange() {
    return _reportService.getCurrentMonthRange();
  }

  @override
  DateTimeRangeEntity getLastMonthRange() {
    return _reportService.getLastMonthRange();
  }

  @override
  DateTimeRangeEntity getLastWeekRange() {
    return _reportService.getLastWeekRange();
  }

  @override
  DateTimeRangeEntity getCustomRange(DateTime start, DateTime end) {
    return _reportService.getCustomRange(start, end);
  }

  @override
  Future<void> saveReportLocally(ReportEntity report, Uint8List data) async {
 try {
      return await _reportService.saveReportLocally(report, data);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> saveReportToFirestore(ReportEntity report) async {
    try {
      return await _reportService.saveReportToFirestore(report);
    } catch (e) {
      return Future.error(e);
    }
  }
}
