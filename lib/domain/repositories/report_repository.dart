// lib/domain/repositories/report_repository.dart
import 'dart:typed_data';
import 'package:check_job/domain/entities/report_entity.dart';

/// Repositorio que expone operaciones de alto nivel que usa la UI / Controller.
/// Implementación concreta delega al [ReportService] y a utilidades de IO.
abstract class ReportRepository {
  /// Genera un reporte y devuelve la entidad resultante.
  /// [additionalFilters] es opcional.
  Future<ReportEntity> generateReport({
    required ReportType type,
    required DateTimeRangeEntity dateRange,
    Map<String, dynamic>? additionalFilters,
  });

  /// Descarga / imprime el reporte (dependiendo del formato y plataforma).
  Future<void> downloadReport(ReportEntity report);

  /// Comparte el reporte (por share sheet).
  Future<void> shareReport(ReportEntity report);

  /// Guarda el reporte en el dispositivo (save dialog).
  Future<void> saveReportToDevice(ReportEntity report);

  /// Obtiene la lista de reportes guardados (metadata).
  Future<List<ReportEntity>> getSavedReports();

  /// Borra un reporte guardado.
  Future<void> deleteSavedReport(String reportId);

  /// Si se desea mantener una copia local en el dispositivo (opcional).
  Future<void> saveReportLocally(ReportEntity report, Uint8List data);

  /// Guarda la metadata y los datos del reporte en Firestore (documento).
  /// Se espera que el objeto `ReportEntity` contenga únicamente los campos
  /// que deben viajar a la BD (reportID, type, dateRange, data, createdAt).
  Future<void> saveReportToFirestore(ReportEntity report);

  /// Utilitarios: formato recomendado y rangos de fecha.
  ReportFormat getRecommendedFormatForType(ReportType type);
  DateTimeRangeEntity getCurrentMonthRange();
  DateTimeRangeEntity getLastMonthRange();
  DateTimeRangeEntity getLastWeekRange();
  DateTimeRangeEntity getCustomRange(DateTime start, DateTime end);
}
