// lib/infraestructure/services/report_service_impl.dart
import 'dart:typed_data';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import 'package:check_job/domain/services/report_service.dart';
import 'package:check_job/domain/entities/report_entity.dart';
import 'package:check_job/domain/entities/enities.dart';

class ReportServiceImpl extends ReportService {
  final FirebaseFirestore _firestore;

  ReportServiceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  // ========== GENERACIÓN PRINCIPAL ==========
  @override
  Future<ReportEntity> generateReport({
    required ReportType type,
    required DateTimeRangeEntity dateRange,
    required ReportFormat format,
    Map<String, dynamic>? additionalFilters,
  }) async {
    try {
      Uint8List reportData;
      Map<String, dynamic> dataToSave = {};

      switch (type) {
        case ReportType.tasks:
          final tasks = await _getTasksInDateRange(dateRange);
          reportData = (format == ReportFormat.pdf)
              ? await _generateTasksPdf(tasks, dateRange)
              : _generateTasksCsv(tasks);

          final summaryTasks = {
            'total_tareas': tasks.length,
            'completadas': tasks
                .where((t) => _normalizeStatus(t.status) == 'completed')
                .length,
            'en_progreso': tasks
                .where((t) => _normalizeStatus(t.status) == 'in_progress')
                .length,
            'pendientes': tasks
                .where((t) => _normalizeStatus(t.status) == 'pending')
                .length,
          };

          final itemsTasks = tasks
              .map(
                (t) => {
                  'taskID': t.taskID,
                  'title': t.title,
                  'description': t.description,
                  'clientName': t.clientName,
                  'assignedEmployeeName': t.assignedEmployeeName,
                  'status': t.status,
                  'createdAt': t.createdAt,
                  'completedAt': t.completedAt is Timestamp
                      ? (t.completedAt as Timestamp)
                      : t.completedAt,
                },
              )
              .toList();

          dataToSave = {'summary': summaryTasks, 'items': itemsTasks};
          break;

        case ReportType.billing:
          final invoices = await _getInvoicesInDateRange(dateRange);
          reportData = (format == ReportFormat.pdf)
              ? await _generateBillingPdf(invoices, dateRange)
              : _generateBillingCsv(invoices);

          final summaryBilling = {
            'total_facturas': invoices.length,
            'pagadas': invoices
                .where((i) => (i.statusText).toLowerCase() == 'paid')
                .length,
            'pendientes': invoices
                .where((i) => (i.statusText).toLowerCase() != 'paid')
                .length,
            'monto_total': invoices.fold<double>(
              0.0,
              (sum, i) => sum + (i.amount),
            ),
          };

          final itemsBilling = invoices
              .map(
                (i) => {
                  'invoicesID': i.invoicesID,
                  'clientName': i.clientName,
                  'amount': i.amount,
                  'statusText': i.statusText,
                  'dueDate': i.dueDate,
                  'createdAt': i.createdAt,
                },
              )
              .toList();

          dataToSave = {'summary': summaryBilling, 'items': itemsBilling};
          break;

        case ReportType.clients:
          final clients = await _getClientsWithActivity();
          reportData = (format == ReportFormat.pdf)
              ? await _generateClientsPdf(clients, dateRange)
              : _generateClientsCsv(clients);

          final summaryClients = {
            'total_clientes': clients.length,
            'activos': clients.where((c) => c.isActive == true).length,
            'inactivos': clients.where((c) => c.isActive != true).length,
          };

          final itemsClients = clients
              .map(
                (c) => {
                  'clientID': c.clientID,
                  'name': c.name,
                  'email': c.email,
                  'phone': c.phone,
                  'createdAt': c.createdAt is Timestamp
                      ? (c.createdAt as Timestamp)
                      : c.createdAt,
                  'isActive': c.isActive,
                },
              )
              .toList();

          dataToSave = {'summary': summaryClients, 'items': itemsClients};
          break;

        case ReportType.inventory:
          final materials = await _getMaterialsSnapshot();
          reportData = (format == ReportFormat.pdf)
              ? await _generateInventoryPdf(materials, dateRange)
              : _generateInventoryCsv(materials);

          final lowStock = materials
              .where((m) => m.currentStock <= m.minStock)
              .length;
          final summaryInventory = {
            'total_materiales': materials.length,
            'stock_bajo': lowStock,
            'stock_ok': materials.length - lowStock,
          };

          final itemsInventory = materials
              .map(
                (m) => {
                  'materialID': m.materialID,
                  'name': m.name,
                  'currentStock': m.currentStock,
                  'minStock': m.minStock,
                  'unit': m.unit,
                  'status': m.status,
                  'updatedAt': m.updatedAt is Timestamp
                      ? (m.updatedAt as Timestamp)
                      : m.updatedAt,
                },
              )
              .toList();

          dataToSave = {'summary': summaryInventory, 'items': itemsInventory};
          break;

        case ReportType.employees:
          final employees = await _getEmployeesWithActivity();
          reportData = (format == ReportFormat.pdf)
              ? await _generateEmployeesPdf(employees, dateRange)
              : _generateEmployeesCsv(employees);

          final summaryEmp = {
            'total_empleados': employees.length,
            'activos': employees.where((e) => e.isActive == true).length,
            'inactivos': employees.where((e) => e.isActive != true).length,
          };

          final itemsEmp = employees
              .map(
                (e) => {
                  'employeesID': e.employeesID,
                  'name': e.name,
                  'email': e.email,
                  'phone': e.phone,
                  'createdAt': e.createdAt is Timestamp
                      ? (e.createdAt as Timestamp)
                      : e.createdAt,
                  'isActive': e.isActive,
                },
              )
              .toList();

          dataToSave = {'summary': summaryEmp, 'items': itemsEmp};
          break;
      }

      // Añadimos información adicional al data
      dataToSave['format'] = (format == ReportFormat.pdf) ? 'pdf' : 'csv';
      dataToSave['sizeBytes'] = reportData.length;

      // Guardar información del período
      dataToSave['period'] = {
        'start': Timestamp.fromDate(dateRange.start),
        'end': Timestamp.fromDate(dateRange.end),
        'display': dateRange.formattedForDisplay,
      };

      final nowTs = Timestamp.now();
      final generatedId = 'report_${DateTime.now().millisecondsSinceEpoch}';
      final newReport = ReportEntity(
        reportId: generatedId,
        type: _firestoreTypeValue(type),
        dateRange: dateRange.formattedForFirestore,
        data: dataToSave,
        createdAt: nowTs,
        fileData: reportData,
        title: 'Reporte de ${_labelFromType(type)}',
        format: format,
        localSizeBytes: reportData.length,
        hasLocalFile: true,
      );

      await saveReportLocally(newReport, reportData);
      await saveReportToFirestore(newReport);

      return newReport;
    } catch (e, st) {
      print('ReportServiceImpl.generateReport error: $e\n$st');
      return Future.error(e);
    }
  }

  // ========== GENERACION INDIVIDUAL (expuestos) ==========
  @override
  Future<Uint8List> generateBillingReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  ) async {
    final invoices = await _getInvoicesInDateRange(dateRange);
    return format == ReportFormat.pdf
        ? await _generateBillingPdf(invoices, dateRange)
        : _generateBillingCsv(invoices);
  }

  @override
  Future<Uint8List> generateClientsReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  ) async {
    final clients = await _getClientsWithActivity();
    return format == ReportFormat.pdf
        ? await _generateClientsPdf(clients, dateRange)
        : _generateClientsCsv(clients);
  }

  @override
  Future<Uint8List> generateEmployeesReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  ) async {
    final employees = await _getEmployeesWithActivity();
    return format == ReportFormat.pdf
        ? await _generateEmployeesPdf(employees, dateRange)
        : _generateEmployeesCsv(employees);
  }

  @override
  Future<Uint8List> generateInventoryReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  ) async {
    final materials = await _getMaterialsSnapshot();
    return format == ReportFormat.pdf
        ? await _generateInventoryPdf(materials, dateRange)
        : _generateInventoryCsv(materials);
  }

  @override
  Future<Uint8List> generateTasksReport(
    DateTimeRangeEntity dateRange,
    ReportFormat format,
  ) async {
    final tasks = await _getTasksInDateRange(dateRange);
    return format == ReportFormat.pdf
        ? await _generateTasksPdf(tasks, dateRange)
        : _generateTasksCsv(tasks);
  }

  // ========== MÉTODOS DE RANGOS DE FECHA ==========
  @override
  DateTimeRangeEntity getCurrentMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateTimeRangeEntity(start: start, end: end);
  }

  @override
  DateTimeRangeEntity getCustomRange(DateTime start, DateTime end) {
    return DateTimeRangeEntity(start: start, end: end);
  }

  @override
  DateTimeRangeEntity getLastMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0, 23, 59, 59);
    return DateTimeRangeEntity(start: start, end: end);
  }

  @override
  DateTimeRangeEntity getLastWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final end = now;
    return DateTimeRangeEntity(start: start, end: end);
  }

  @override
  ReportFormat getRecommendedFormatForType(ReportType type) {
    switch (type) {
      case ReportType.tasks:
      case ReportType.billing:
        return ReportFormat.pdf;
      case ReportType.clients:
      case ReportType.inventory:
      case ReportType.employees:
        return ReportFormat.csv;
    }
  }

  // ---------- SAVE LOCAL ----------
  @override
  Future<void> saveReportLocally(ReportEntity report, Uint8List data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');
      if (!await reportsDir.exists()) await reportsDir.create(recursive: true);

      final sanitizedTitle = (report.title ?? '').replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      final fileName =
          '${report.reportId}_${sanitizedTitle.isNotEmpty ? sanitizedTitle : report.reportId}';
      final ext = (report.format == ReportFormat.csv) ? 'csv' : 'pdf';
      final file = File('${reportsDir.path}/$fileName.$ext');
      await file.writeAsBytes(data, flush: true);
      return;
    } catch (e, st) {
      print('Error saving report locally: $e\n$st');
      return Future.error(e);
    }
  }

  // ---------- OBTENER DATOS PARA DESCARGA ----------
  @override
  Future<Uint8List> getReportData(ReportEntity report) async {
    try {
      if (report.fileData != null) return report.fileData!;

      // Intentar leer archivo local que contenga reportId en su nombre
      try {
        final directory = await getApplicationDocumentsDirectory();
        final reportsDir = Directory('${directory.path}/reports');
        if (await reportsDir.exists()) {
          final files = reportsDir.listSync();
          for (final f in files) {
            if (f is File &&
                f.uri.pathSegments.last.contains(report.reportId)) {
              final bytes = await f.readAsBytes();
              return bytes;
            }
          }
        }
      } catch (_) {
        // ignorar, intentaremos regenerar
      }

      // Si report.data contiene items, regenerar desde esos items
      final type = _typeFromFirestoreValue(report.type);
      final ReportFormat format =
          report.format ?? _reportFormatFromData(report.data);

      if (report.data.containsKey('items') && report.data['items'] is List) {
        final List items = report.data['items'] as List;
        switch (type) {
          case ReportType.tasks:
            final tasks = items
                .map((m) => TaskEntity.fromMap(Map<String, dynamic>.from(m)))
                .toList();
            return format == ReportFormat.pdf
                ? await _generateTasksPdf(
                    tasks,
                    _parseDateRangeFromData(report.data, report.dateRange),
                  )
                : _generateTasksCsv(tasks);
          case ReportType.billing:
            final invoices = items
                .map(
                  (m) =>
                      InvoiceEntity.fromFirestore(Map<String, dynamic>.from(m)),
                )
                .toList();
            return format == ReportFormat.pdf
                ? await _generateBillingPdf(
                    invoices,
                    _parseDateRangeFromData(report.data, report.dateRange),
                  )
                : _generateBillingCsv(invoices);
          case ReportType.clients:
            final clients = items
                .map(
                  (m) =>
                      ClientEntity.fromFirestore(Map<String, dynamic>.from(m)),
                )
                .toList();
            return format == ReportFormat.pdf
                ? await _generateClientsPdf(
                    clients,
                    _parseDateRangeFromData(report.data, report.dateRange),
                  )
                : _generateClientsCsv(clients);
          case ReportType.inventory:
            final materials = items
                .map(
                  (m) => MaterialEntity.fromFirestore(
                    Map<String, dynamic>.from(m),
                  ),
                )
                .toList();
            return format == ReportFormat.pdf
                ? await _generateInventoryPdf(
                    materials,
                    _parseDateRangeFromData(report.data, report.dateRange),
                  )
                : _generateInventoryCsv(materials);
          case ReportType.employees:
            final employees = items
                .map(
                  (m) => EmployeeEntity.fromFirestore(
                    Map<String, dynamic>.from(m),
                  ),
                )
                .toList();
            return format == ReportFormat.pdf
                ? await _generateEmployeesPdf(
                    employees,
                    _parseDateRangeFromData(report.data, report.dateRange),
                  )
                : _generateEmployeesCsv(employees);
        }
      }

      // Fallback: regenerar usando generateReport
      final parsedRange = _parseDateRangeFromData(
        report.data,
        report.dateRange,
      );
      final regenerated = await generateReport(
        type: type,
        dateRange: parsedRange,
        format: format,
      );
      if (regenerated.fileData != null) return regenerated.fileData!;
      return Future.error('No se pudo obtener datos del reporte');
    } catch (e, st) {
      print('Error getReportData: $e\n$st');
      return Future.error(e);
    }
  }

  // ========== FIRESTORE CRUD ==========
  @override
  Future<void> saveReportToFirestore(ReportEntity report) async {
    try {
      await _firestore
          .collection('reports')
          .doc(report.reportId)
          .set(report.toFirestoreMap());
      return;
    } catch (e, st) {
      print('Error saveReportToFirestore: $e\n$st');
      return Future.error(e);
    }
  }

  @override
  Future<List<ReportEntity>> getSavedReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));
      final List<ReportEntity> list = [];

      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');
      final bool reportsDirExists = await reportsDir.exists();
      final localFiles = reportsDirExists ? reportsDir.listSync() : [];

      for (final doc in snapshot.docs) {
        final map = doc.data();
        var report = ReportEntity.fromMap(map, fallbackId: doc.id);

        // Si data contiene format, asegurar format en la entidad
        if (report.format == null) {
          final String? fmtStr = report.data['format'] is String
              ? (report.data['format'] as String?)
              : null;
          if (fmtStr != null) {
            report = report.copyWith(format: ReportFormat.fromString(fmtStr));
          }
        }

        // Buscar archivo local que contenga reportId y obtener tamaño
        int? localSize;
        bool hasLocal = false;

        try {
          if (reportsDirExists) {
            for (final f in localFiles) {
              if (f is File && f.path.contains(report.reportId)) {
                try {
                  final fileSize = await f.length();
                  localSize = fileSize;
                  hasLocal = true;
                  break;
                } catch (_) {}
              }
            }
          }
        } catch (_) {}

        // Actualizar entidad con información local
        report = report.copyWith(
          localSizeBytes: localSize ?? report.data['sizeBytes'],
          hasLocalFile: hasLocal,
        );

        list.add(report);
      }

      return list;
    } catch (e, st) {
      print('Error getSavedReports: $e\n$st');
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteSavedReport(String reportId) async {
    try {
      final docRef = _firestore.collection('reports').doc(reportId);
      final doc = await docRef.get(GetOptions(source: Source.server));
      if (doc.exists) {
        await docRef.delete();
      }

      // borrar archivos locales que contengan reportId
      try {
        final directory = await getApplicationDocumentsDirectory();
        final reportsDir = Directory('${directory.path}/reports');
        if (await reportsDir.exists()) {
          final files = reportsDir.listSync();
          for (final f in files) {
            if (f is File && f.uri.pathSegments.last.contains(reportId)) {
              try {
                await f.delete();
              } catch (_) {}
            }
          }
        }
      } catch (_) {}

      return;
    } catch (e, st) {
      print('Error deleteSavedReport: $e\n$st');
      return Future.error(e);
    }
  }

  // ========== MÉTODOS PRIVADOS: CONSULTAS A FIRESTORE ==========
  Future<List<TaskEntity>> _getTasksInDateRange(
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          )
          .get(GetOptions(source: Source.server));

      return snapshot.docs.map((d) => TaskEntity.fromMap(d.data())).toList();
    } catch (e, st) {
      print('Error _getTasksInDateRange: $e\n$st');
      return [];
    }
  }

  Future<List<InvoiceEntity>> _getInvoicesInDateRange(
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          )
          .get(GetOptions(source: Source.server));

      return snapshot.docs
          .map((d) => InvoiceEntity.fromFirestore(d.data()))
          .toList();
    } catch (e, st) {
      print('Error _getInvoicesInDateRange: $e\n$st');
      return [];
    }
  }

  Future<List<ClientEntity>> _getClientsWithActivity() async {
    try {
      final snapshot = await _firestore.collection('clients').get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((d) => ClientEntity.fromFirestore(d.data()))
          .toList();
    } catch (e, st) {
      print('Error _getClientsWithActivity: $e\n$st');
      return [];
    }
  }

  Future<List<MaterialEntity>> _getMaterialsSnapshot() async {
    try {
      final snapshot = await _firestore.collection('materials').get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((d) => MaterialEntity.fromFirestore(d.data()))
          .toList();
    } catch (e, st) {
      print('Error _getMaterialsSnapshot: $e\n$st');
      return [];
    }
  }

  Future<List<EmployeeEntity>> _getEmployeesWithActivity() async {
    try {
      final snapshot = await _firestore.collection('employees').get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((d) => EmployeeEntity.fromFirestore(d.data()))
          .toList();
    } catch (e, st) {
      print('Error _getEmployeesWithActivity: $e\n$st');
      return [];
    }
  }

  // ========== GENERACIÓN DE PDFs ==========
  Future<Uint8List> _generateTasksPdf(
    List<TaskEntity> tasks,
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              _buildPdfHeader('Reporte de Tareas', dateRange),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen: ${tasks.length} tareas encontradas',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildTasksTable(tasks),
              pw.SizedBox(height: 20),
              _buildPdfFooter(),
            ];
          },
        ),
      );
      return pdf.save();
    } catch (e, st) {
      print('Error _generateTasksPdf: $e\n$st');
      return Future.error(e);
    }
  }

  Future<Uint8List> _generateBillingPdf(
    List<InvoiceEntity> invoices,
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              _buildPdfHeader('Reporte de Facturación', dateRange),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen: ${invoices.length} facturas encontradas',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildInvoicesTable(invoices),
              pw.SizedBox(height: 20),
              _buildPdfFooter(),
            ];
          },
        ),
      );
      return pdf.save();
    } catch (e, st) {
      print('Error _generateBillingPdf: $e\n$st');
      return Future.error(e);
    }
  }

  Future<Uint8List> _generateClientsPdf(
    List<ClientEntity> clients,
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              _buildPdfHeader('Reporte de Clientes', dateRange),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen: ${clients.length} clientes encontrados',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildClientsTable(clients),
              pw.SizedBox(height: 20),
              _buildPdfFooter(),
            ];
          },
        ),
      );
      return pdf.save();
    } catch (e, st) {
      print('Error _generateClientsPdf: $e\n$st');
      return Future.error(e);
    }
  }

  Future<Uint8List> _generateInventoryPdf(
    List<MaterialEntity> materials,
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              _buildPdfHeader('Reporte de Inventario', dateRange),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen: ${materials.length} materiales encontrados',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildInventoryTable(materials),
              pw.SizedBox(height: 20),
              _buildPdfFooter(),
            ];
          },
        ),
      );
      return pdf.save();
    } catch (e, st) {
      print('Error _generateInventoryPdf: $e\n$st');
      return Future.error(e);
    }
  }

  Future<Uint8List> _generateEmployeesPdf(
    List<EmployeeEntity> employees,
    DateTimeRangeEntity dateRange,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              _buildPdfHeader('Reporte de Empleados', dateRange),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen: ${employees.length} empleados encontrados',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildEmployeesTable(employees),
              pw.SizedBox(height: 20),
              _buildPdfFooter(),
            ];
          },
        ),
      );
      return pdf.save();
    } catch (e, st) {
      print('Error _generateEmployeesPdf: $e\n$st');
      return Future.error(e);
    }
  }

  // ========== GENERACIÓN DE CSVs ==========
  Uint8List _generateTasksCsv(List<TaskEntity> tasks) {
    try {
      final rows = <List<dynamic>>[];
      rows.add([
        'ID',
        'Título',
        'Descripción',
        'Cliente',
        'Empleado',
        'Estado',
        'Fecha Creación',
        'Fecha Completación',
      ]);
      for (final t in tasks) {
        rows.add([
          t.taskID,
          t.title,
          t.description,
          t.clientName,
          t.assignedEmployeeName,
          _formatStatus(t.status),
          _maybeFormatTimestampOrDate(t.createdAt),
          t.completedAt != null
              ? _maybeFormatTimestampOrDate(t.completedAt)
              : 'No completada',
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      return Uint8List.fromList(csv.codeUnits);
    } catch (e, st) {
      print('Error _generateTasksCsv: $e\n$st');
      throw Exception(e.toString());
    }
  }

  Uint8List _generateBillingCsv(List<InvoiceEntity> invoices) {
    try {
      final rows = <List<dynamic>>[];
      rows.add([
        'ID',
        'Cliente',
        'Monto',
        'Estado',
        'Fecha Vencimiento',
        'Fecha Creación',
      ]);
      for (final i in invoices) {
        rows.add([
          i.invoicesID,
          i.clientName,
          i.amount,
          i.statusText,
          _maybeFormatTimestampOrDate(i.dueDate),
          _maybeFormatTimestampOrDate(i.createdAt),
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      return Uint8List.fromList(csv.codeUnits);
    } catch (e, st) {
      print('Error _generateBillingCsv: $e\n$st');
      throw Exception(e.toString());
    }
  }

  Uint8List _generateClientsCsv(List<ClientEntity> clients) {
    try {
      final rows = <List<dynamic>>[];
      rows.add([
        'ID',
        'Nombre',
        'Email',
        'Teléfono',
        'Fecha Registro',
        'Estado',
      ]);
      for (final c in clients) {
        rows.add([
          c.clientID,
          c.name,
          c.email,
          c.phone,
          _maybeFormatTimestampOrDate(c.createdAt),
          c.isActive == true ? 'Activo' : 'Inactivo',
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      return Uint8List.fromList(csv.codeUnits);
    } catch (e, st) {
      print('Error _generateClientsCsv: $e\n$st');
      throw Exception(e.toString());
    }
  }

  Uint8List _generateInventoryCsv(List<MaterialEntity> materials) {
    try {
      final rows = <List<dynamic>>[];
      rows.add([
        'ID',
        'Material',
        'Stock Actual',
        'Stock Mínimo',
        'Unidad',
        'Estado',
        'Última Actualización',
      ]);
      for (final m in materials) {
        rows.add([
          m.materialID,
          m.name,
          m.currentStock,
          m.minStock,
          m.unit,
          m.status,
          _maybeFormatTimestampOrDate(m.updatedAt),
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      return Uint8List.fromList(csv.codeUnits);
    } catch (e, st) {
      print('Error _generateInventoryCsv: $e\n$st');
      throw Exception(e.toString());
    }
  }

  Uint8List _generateEmployeesCsv(List<EmployeeEntity> employees) {
    try {
      final rows = <List<dynamic>>[];
      rows.add([
        'ID',
        'Nombre',
        'Email',
        'Teléfono',
        'Fecha Registro',
        'Estado',
      ]);
      for (final e in employees) {
        rows.add([
          e.employeesID,
          e.name,
          e.email,
          e.phone,
          _maybeFormatTimestampOrDate(e.createdAt),
          e.isActive == true ? 'Activo' : 'Inactivo',
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      return Uint8List.fromList(csv.codeUnits);
    } catch (e, st) {
      print('Error _generateEmployeesCsv: $e\n$st');
      throw Exception(e.toString());
    }
  }

  // ========== COMPONENTES PDF ==========
  pw.Widget _buildPdfHeader(String title, DateTimeRangeEntity dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'CheckJob App',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Reporte',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Período: ${dateRange.formattedForDisplay}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generado el: ${_formatDate(DateTime.now())} • CheckJob App',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildTasksTable(List<TaskEntity> tasks) {
    final data = tasks
        .map(
          (t) => [
            t.taskID.length > 8 ? '${t.taskID.substring(0, 8)}...' : t.taskID,
            t.title.length > 20 ? '${t.title.substring(0, 20)}...' : t.title,
            t.clientName.length > 15
                ? '${t.clientName.substring(0, 15)}...'
                : t.clientName,
            t.assignedEmployeeName.length > 15
                ? '${t.assignedEmployeeName.substring(0, 15)}...'
                : t.assignedEmployeeName,
            _formatStatus(t.status),
            _maybeFormatTimestampOrDate(t.createdAt),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Título', 'Cliente', 'Empleado', 'Estado', 'Fecha'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
    );
  }

  pw.Widget _buildInvoicesTable(List<InvoiceEntity> invoices) {
    final data = invoices
        .map(
          (i) => [
            i.invoicesID.length > 8
                ? '${i.invoicesID.substring(0, 8)}...'
                : i.invoicesID,
            i.clientName.length > 20
                ? '${i.clientName.substring(0, 20)}...'
                : i.clientName,
            '\$${(i.amount).toStringAsFixed(2)}',
            i.statusText,
            _maybeFormatTimestampOrDate(i.dueDate),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Cliente', 'Monto', 'Estado', 'Vencimiento'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
    );
  }

  pw.Widget _buildClientsTable(List<ClientEntity> clients) {
    final data = clients
        .map(
          (c) => [
            c.clientID.length > 8
                ? '${c.clientID.substring(0, 8)}...'
                : c.clientID,
            c.name.length > 20 ? '${c.name.substring(0, 20)}...' : c.name,
            c.email.length > 25 ? '${c.email.substring(0, 25)}...' : c.email,
            c.phone,
            _maybeFormatTimestampOrDate(c.createdAt),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Nombre', 'Email', 'Teléfono', 'Fecha Registro'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
    );
  }

  pw.Widget _buildInventoryTable(List<MaterialEntity> materials) {
    final data = materials
        .map(
          (m) => [
            m.materialID.length > 8
                ? '${m.materialID.substring(0, 8)}...'
                : m.materialID,
            m.name.length > 20 ? '${m.name.substring(0, 20)}...' : m.name,
            m.currentStock.toString(),
            m.minStock.toString(),
            m.unit,
            m.status,
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Material', 'Stock', 'Mínimo', 'Unidad', 'Estado'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
    );
  }

  pw.Widget _buildEmployeesTable(List<EmployeeEntity> employees) {
    final data = employees
        .map(
          (e) => [
            e.employeesID.length > 8
                ? '${e.employeesID.substring(0, 8)}...'
                : e.employeesID,
            e.name.length > 20 ? '${e.name.substring(0, 20)}...' : e.name,
            e.email.length > 25 ? '${e.email.substring(0, 25)}...' : e.email,
            e.phone,
            _maybeFormatTimestampOrDate(e.createdAt),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: ['ID', 'Nombre', 'Email', 'Teléfono', 'Fecha Registro'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
    );
  }

  // ========== HELPERS ==========
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _maybeFormatTimestampOrDate(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      return _formatDate(value.toDate());
    } else if (value is DateTime) {
      return _formatDate(value);
    } else if (value is String) {
      // intentar parsear ISO
      try {
        final dt = DateTime.parse(value);
        return _formatDate(dt);
      } catch (_) {
        return value;
      }
    } else {
      return value.toString();
    }
  }

  String _formatStatus(String status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return 'Pendiente';
      case 'in_progress':
        return 'En Proceso';
      case 'completed':
        return 'Completado';
      default:
        return status;
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null) return '';
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('completado')) return 'completed';
    if (s.contains('in_progress') || s.contains('en_progreso'))
      return 'in_progress';
    if (s.contains('pending') || s.contains('pendiente')) return 'pending';
    return s;
  }

  String _firestoreTypeValue(ReportType t) {
    switch (t) {
      case ReportType.tasks:
        return 'tareas_mensuales';
      case ReportType.billing:
        return 'facturacion_mensual';
      case ReportType.clients:
        return 'clientes_mensual';
      case ReportType.inventory:
        return 'inventario_mensual';
      case ReportType.employees:
        return 'empleados_mensual';
    }
  }

  ReportType _typeFromFirestoreValue(String v) {
    switch (v) {
      case 'tareas_mensuales':
        return ReportType.tasks;
      case 'facturacion_mensual':
        return ReportType.billing;
      case 'clientes_mensual':
        return ReportType.clients;
      case 'inventario_mensual':
        return ReportType.inventory;
      case 'empleados_mensual':
        return ReportType.employees;
      default:
        return ReportType.tasks;
    }
  }

  String _labelFromType(ReportType t) {
    switch (t) {
      case ReportType.tasks:
        return 'Tareas';
      case ReportType.billing:
        return 'Facturación';
      case ReportType.clients:
        return 'Clientes';
      case ReportType.inventory:
        return 'Inventario';
      case ReportType.employees:
        return 'Empleados';
    }
  }

  DateTimeRangeEntity _parseDateRangeFromFirestore(String dateRangeString) {
    try {
      final parts = dateRangeString.split(' ');
      if (parts.length >= 2) {
        final monthName = parts[0];
        final year = int.tryParse(parts[1]) ?? DateTime.now().year;
        final month = _getMonthNumber(monthName);
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0, 23, 59, 59);
        return DateTimeRangeEntity(start: start, end: end);
      }
    } catch (_) {}
    final now = DateTime.now();
    return DateTimeRangeEntity(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  DateTimeRangeEntity _parseDateRangeFromData(
    Map<String, dynamic>? data,
    String fallbackDateRange,
  ) {
    try {
      if (data != null && data.containsKey('period') && data['period'] is Map) {
        final p = Map<String, dynamic>.from(data['period']);
        final start = (p['start'] is Timestamp)
            ? (p['start'] as Timestamp).toDate()
            : (p['start'] is DateTime ? p['start'] : null);
        final end = (p['end'] is Timestamp)
            ? (p['end'] as Timestamp).toDate()
            : (p['end'] is DateTime ? p['end'] : null);
        if (start != null && end != null)
          return DateTimeRangeEntity(start: start, end: end);
      }
    } catch (_) {}
    return _parseDateRangeFromFirestore(fallbackDateRange);
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Enero': 1,
      'Febrero': 2,
      'Marzo': 3,
      'Abril': 4,
      'Mayo': 5,
      'Junio': 6,
      'Julio': 7,
      'Agosto': 8,
      'Septiembre': 9,
      'Octubre': 10,
      'Noviembre': 11,
      'Diciembre': 12,
    };
    return months[monthName] ?? DateTime.now().month;
  }

  ReportFormat _reportFormatFromData(Map<String, dynamic>? data) {
    try {
      if (data != null && data.containsKey('format')) {
        final f = data['format'];
        if (f is String) {
          final lf = f.toLowerCase();
          if (lf == 'pdf') return ReportFormat.pdf;
          if (lf == 'csv') return ReportFormat.csv;
        }
      }
    } catch (_) {}
    return ReportFormat.pdf;
  }
}
