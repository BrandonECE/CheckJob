// lib/domain/services/report_service.dart
import 'dart:typed_data';
import 'package:check_job/domain/entities/report_entity.dart';

/// Servicio encargado de la lógica de generación de reportes,
/// acceso a datos necesarios para generarlos y persistencia en Firestore.
abstract class ReportService {
  /// Genera un reporte (contenido en bytes) y también retorna la entidad
  /// con metadata y con `fileData` llenado.
  ///
  /// [type]      : tipo lógico del reporte (enum ReportType).
  /// [dateRange] : rango de fechas utilizado para filtrar los datos.
  /// [format]    : formato de salida (PDF/CSV).
  /// [additionalFilters] : filtros opcionales dependiendo del tipo.
  Future<ReportEntity> generateReport({
    required ReportType type,
    required DateTimeRangeEntity dateRange,
    required ReportFormat format,
    Map<String, dynamic>? additionalFilters,
  });

  /// Si se desea mantener una copia local en el dispositivo (opcional).
  Future<void> saveReportLocally(ReportEntity report, Uint8List data);

  /// Obtiene los bytes del reporte para descargar/compartir.
  /// Si la entidad ya contiene fileData lo devuelve; si no, puede regenerar
  /// el reporte a partir del campo `data` o consultando la DB.
  Future<Uint8List> getReportData(ReportEntity report);

  /// Guarda la metadata y los datos del reporte en Firestore (documento).
  /// Se espera que el objeto `ReportEntity` contenga únicamente los campos
  /// que deben viajar a la BD (reportID, type, dateRange, data, createdAt).
  Future<void> saveReportToFirestore(ReportEntity report);

  /// Obtiene la lista de reportes guardados (metadata + data) desde Firestore.
  Future<List<ReportEntity>> getSavedReports();

  /// Elimina el reporte guardado en Firestore (y opcionalmente recursos locales).
  Future<void> deleteSavedReport(String reportId);

  /// Métodos auxiliares para generación de reportes específicos (opcional,
  /// pueden ser implementados por el servicio concreto).
  Future<Uint8List> generateTasksReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  );
  Future<Uint8List> generateBillingReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  );
  Future<Uint8List> generateClientsReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  );
  Future<Uint8List> generateInventoryReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  );
  Future<Uint8List> generateEmployeesReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  );

  /// Utilitarios de rangos y formato recomendado
  ReportFormat getRecommendedFormatForType(ReportType type);
  DateTimeRangeEntity getCurrentMonthRange();
  DateTimeRangeEntity getLastMonthRange();
  DateTimeRangeEntity getLastWeekRange();
  DateTimeRangeEntity getCustomRange(DateTime start, DateTime end);
}
