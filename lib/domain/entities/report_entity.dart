// lib/domain/entities/report_entity.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReportFormat {
  pdf('PDF', Icons.picture_as_pdf, Colors.red),
  csv('CSV', Icons.table_chart, Colors.green);

  final String label;
  final IconData icon;
  final Color color;
  const ReportFormat(this.label, this.icon, this.color);

  static ReportFormat? fromString(String? s) {
    if (s == null) return null;
    final low = s.toLowerCase();
    if (low == 'pdf') return ReportFormat.pdf;
    if (low == 'csv') return ReportFormat.csv;
    return null;
  }

  String toShortString() {
    return name; // 'pdf' or 'csv'
  }
}

class ReportEntity {
  final String reportId; // propiedad usada en el resto del proyecto
  final String type; // valor para Firestore (ej. 'tareas_mensuales')
  final String dateRange; // string (ej. "Noviembre 2023")
  final Map<String, dynamic> data; // aquí guardamos summary + items + format
  final Timestamp createdAt;

  // campos locales no guardados en Firestore
  final Uint8List? fileData;
  final String? title;
  final ReportFormat? format;

  // campos locales NO persistidos en Firestore (solo para UI / funcionalidad local)
  final int? localSizeBytes;
  final bool hasLocalFile;

  ReportEntity({
    required this.reportId,
    required this.type,
    required this.dateRange,
    required this.data,
    required this.createdAt,
    this.fileData,
    this.title,
    this.format,
    this.localSizeBytes,
    this.hasLocalFile = false,
  });

  // Mapa para guardar en Firestore (solo los campos que mencionaste)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'reportID': reportId,
      'type': type,
      'dateRange': dateRange,
      'data': data,
      'createdAt': createdAt,
      // title/format/local size NO se guardan en Firestore (format se encuentra dentro de data)
    };
  }

  // Crear desde mapa (p. ej. snapshot.data())
  factory ReportEntity.fromMap(Map<String, dynamic> map, {String? fallbackId}) {
    final String id = (map['reportID'] as String?) ?? fallbackId ?? '';
    final created = (map['createdAt'] as Timestamp?) ?? Timestamp.now();
    final Map<String, dynamic> dataMap = map['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(map['data'])
        : <String, dynamic>{};

    // leer formato si viene dentro de data (esperamos: data['format'] == 'pdf'|'csv')
    final String? fmtStr = dataMap['format'] is String
        ? (dataMap['format'] as String?)
        : null;
    final ReportFormat? fmt = ReportFormat.fromString(fmtStr);

    return ReportEntity(
      reportId: id,
      type: (map['type'] as String?) ?? '',
      dateRange: (map['dateRange'] as String?) ?? '',
      data: dataMap,
      createdAt: created,
      fileData: null,
      title: (map['title'] as String?) ?? null,
      format: fmt,
      localSizeBytes: null,
      hasLocalFile: false,
    );
  }

  // Crear desde DocumentSnapshot
  factory ReportEntity.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ReportEntity.fromMap(map, fallbackId: doc.id);
  }

  // copyWith para que el servicio pueda añadir tamaño / hasLocalFile / fileData
  ReportEntity copyWith({
    Uint8List? fileData,
    String? title,
    ReportFormat? format,
    int? localSizeBytes,
    bool? hasLocalFile,
    Map<String, dynamic>? data,
  }) {
    return ReportEntity(
      reportId: reportId,
      type: type,
      dateRange: dateRange,
      data: data ?? this.data,
      createdAt: createdAt,
      fileData: fileData ?? this.fileData,
      title: title ?? this.title,
      format: format ?? this.format,
      localSizeBytes: localSizeBytes ?? this.localSizeBytes,
      hasLocalFile: hasLocalFile ?? this.hasLocalFile,
    );
  }

  // Helper UI
  String get formattedForDisplay {
    return dateRange;
  }

  String get formattedSize {
    final bytes = localSizeBytes ?? (fileData?.length);
    if (bytes == null) return 'N/A';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  static String _titleFromType(String t) {
    switch (t) {
      case 'tareas_mensuales':
        return 'Reporte de Tareas';
      case 'facturacion_mensual':
        return 'Reporte de Facturación';
      case 'clientes_mensual':
        return 'Reporte de Clientes';
      case 'inventario_mensual':
        return 'Reporte de Inventario';
      case 'empleados_mensual':
        return 'Reporte de Empleados';
      default:
        return 'Reporte';
    }
  }

  String get titleForUI => _titleFromType(type);
}

enum DateRangeOption {
  currentMonth('Este mes'),
  lastMonth('Mes anterior'),
  lastWeek('Última semana'),
  custom('Rango personalizado');

  final String label;
  const DateRangeOption(this.label);
}

class DateTimeRangeEntity {
  final DateTime start;
  final DateTime end;
  DateTimeRangeEntity({required this.start, required this.end});

  String get formattedForDisplay {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${start.day.toString().padLeft(2, '0')} ${months[start.month - 1]} ${start.year} - ${end.day.toString().padLeft(2, '0')} ${months[end.month - 1]} ${end.year}';
  }

  String get formattedForFirestore {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    // Función auxiliar para formatear fecha como dd/mm/yyyy
    String formatDateToDMY(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    // Formatear el rango completo de fechas
    final dateRangeFormatted = '${formatDateToDMY(start)} - ${formatDateToDMY(end)}';

    // Lógica para determinar el formato del período
    if (start.year == end.year && start.month == end.month) {
      // Mismo mes y mismo año: "Oct 2025 _12/10/2025 - 15/10/2025"
      return '${months[end.month - 1]} ${end.year} _$dateRangeFormatted';
    } else if (start.year == end.year) {
      return '${months[start.month - 1]} - ${months[end.month - 1]} ${end.year} _$dateRangeFormatted';
    } else {
      // Diferente año: "Sep 2024 - Oct 2025 _23/09/2024 - 15/10/2025"
      return '${months[start.month - 1]} ${start.year} - ${months[end.month - 1]} ${end.year} _$dateRangeFormatted';
    }
  }
}

enum ReportType {
  tasks(
    'Tareas',
    Icons.task,
    'Reporte detallado de todas las tareas',
    'tareas_mensuales',
  ),
  billing(
    'Facturación',
    Icons.receipt,
    'Reporte de facturas y pagos',
    'facturacion_mensual',
  ),
  clients(
    'Clientes',
    Icons.people,
    'Reporte de clientes y su actividad',
    'clientes_mensual',
  ),
  inventory(
    'Inventario',
    Icons.inventory,
    'Reporte de materiales y stock',
    'inventario_mensual',
  ),
  employees(
    'Empleados',
    Icons.engineering,
    'Reporte de empleados y productividad',
    'empleados_mensual',
  );

  final String label;
  final IconData icon;
  final String description;
  final String firestoreValue;
  const ReportType(
    this.label,
    this.icon,
    this.description,
    this.firestoreValue,
  );

  static ReportType fromFirestoreValue(String value) {
    return ReportType.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => ReportType.tasks,
    );
  }
}
