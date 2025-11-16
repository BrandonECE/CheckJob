// lib/infraestructure/repositories/statistic_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/repositories/statistics_repository.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../domain/entities/enities.dart';

class StatisticRepositoryImpl implements StatisticRepository {
  final FirebaseFirestore _firestore;

  StatisticRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Stream<List<StatisticEntity>> getStatistics() {
    try {
      return _firestore
          .collection('statistics')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => StatisticEntity.fromFirestore(d.data(), d.id)).toList());
    } catch (e) {
      throw Exception('Error inicializando stream de statistics: $e');
    }
  }

  @override
  Future<List<StatisticEntity>> getStatisticsOnce() async {
    try {
      final snapshot = await _firestore.collection('statistics').orderBy('date', descending: true).get();
      return snapshot.docs.map((d) => StatisticEntity.fromFirestore(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Error getStatisticsOnce: $e');
    }
  }

  @override
  Future<List<StatisticEntity>> getStatisticsByMetric(String metric) async {
    try {
      final snapshot = await _firestore.collection('statistics').where('metric', isEqualTo: metric).orderBy('date', descending: true).get();
      return snapshot.docs.map((d) => StatisticEntity.fromFirestore(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Error getStatisticsByMetric: $e');
    }
  }

  @override
  Future<List<StatisticEntity>> getStatisticsByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore.collection('statistics').where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('date', isLessThanOrEqualTo: Timestamp.fromDate(end)).orderBy('date', descending: true).get();
      return snapshot.docs.map((d) => StatisticEntity.fromFirestore(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Error getStatisticsByDateRange: $e');
    }
  }

  @override
  Future<List<StatisticEntity>> getStatisticsByMetricAndDateRange(String metric, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore.collection('statistics').where('metric', isEqualTo: metric).where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('date', isLessThanOrEqualTo: Timestamp.fromDate(end)).orderBy('date', descending: true).get();
      return snapshot.docs.map((d) => StatisticEntity.fromFirestore(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Error getStatisticsByMetricAndDateRange: $e');
    }
  }

  @override
  Future<void> createStatistic(StatisticEntity statistic) async {
    try {
      await _firestore.collection('statistics').doc(statistic.statisticID).set(statistic.toFirestore());
    } catch (e) {
      throw Exception('Error createStatistic: $e');
    }
  }

  /// Implementación de agregación simple para getStatsForPeriod
  /// Lógica: obtiene todos los documentos en el rango y agrega valores numéricos por suma.
  /// Para 'completion_rate' y otros ratios se recalculan si hay 'total_tasks' y 'completed_tasks'.
  // lib/infraestructure/repositories/statistic_repository_impl.dart
// REEMPLAZA completamente el método getStatsForPeriod:

@override
Future<Map<String, dynamic>> getStatsForPeriod(DateTimeRange dateRange) async {
  try {
    print('📊 Buscando estadísticas para rango: ${dateRange.start} hasta ${dateRange.end}');
    
    final snapshot = await _firestore.collection('statistics')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
        .get();

    print('📄 Documentos encontrados: ${snapshot.docs.length}');

    // Inicializar acumuladores para cada métrica
    final Map<String, double> metricSums = {
      'total_tasks': 0.0,
      'completed_tasks': 0.0,
      'pending_tasks': 0.0,
      'in_progress_tasks': 0.0,
      'monthly_income': 0.0,
      'active_clients': 0.0,
      'completion_rate': 0.0,
      'average_task_time': 0.0,
      'client_satisfaction': 0.0,
      'productivity_index': 0.0,
      'productive_employees': 0.0,
      'total_tasks_completed': 0.0,
    };

    final Map<String, int> metricCounts = {
      'completion_rate': 0,
      'average_task_time': 0,
      'client_satisfaction': 0,
      'productivity_index': 0,
    };

    // Procesar cada documento
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final metric = data['metric'] as String?;
      final value = data['value'];

      print('📋 Procesando documento: $metric = $value');

      if (metric != null && value != null) {
        double numericValue = 0.0;
        
        // Convertir el valor a double
        if (value is num) {
          numericValue = value.toDouble();
        } else if (value is String) {
          numericValue = double.tryParse(value) ?? 0.0;
        }

        // Acumular según el tipo de métrica
        if (metricSums.containsKey(metric)) {
          // Para métricas acumulativas (sumar)
          if (_isAccumulativeMetric(metric)) {
            metricSums[metric] = metricSums[metric]! + numericValue;
          } 
          // Para métricas de promedio (acumular para luego promediar)
          else if (_isAverageMetric(metric)) {
            metricSums[metric] = metricSums[metric]! + numericValue;
            metricCounts[metric] = (metricCounts[metric] ?? 0) + 1;
          }
        }
      }
    }

    // Calcular promedios para las métricas que lo requieren
    _calculateAverages(metricSums, metricCounts);

    // Calcular completion_rate si tenemos los datos
    final totalTasks = metricSums['total_tasks']!;
    final completedTasks = metricSums['completed_tasks']!;
    if (totalTasks > 0) {
      metricSums['completion_rate'] = (completedTasks / totalTasks) * 100.0;
    }

    print('🎯 Métricas calculadas: $metricSums');

    return _formatFinalStats(metricSums);
  } catch (e) {
    print('❌ Error en getStatsForPeriod: $e');
    throw Exception('Error getStatsForPeriod: $e');
  }
}

// Helper: Identificar métricas acumulativas (se suman)
bool _isAccumulativeMetric(String metric) {
  return [
    'total_tasks',
    'completed_tasks', 
    'pending_tasks',
    'in_progress_tasks',
    'monthly_income',
    'active_clients',
    'productive_employees',
    'total_tasks_completed',
  ].contains(metric);
}

// Helper: Identificar métricas de promedio (se promedian)
bool _isAverageMetric(String metric) {
  return [
    'completion_rate',
    'average_task_time', 
    'client_satisfaction',
    'productivity_index',
  ].contains(metric);
}

// Helper: Calcular promedios
void _calculateAverages(Map<String, double> metricSums, Map<String, int> metricCounts) {
  metricCounts.forEach((metric, count) {
    if (count > 0 && metricSums.containsKey(metric)) {
      metricSums[metric] = metricSums[metric]! / count;
    }
  });
}

// Helper: Formatear estadísticas finales
Map<String, dynamic> _formatFinalStats(Map<String, double> metricSums) {
  return {
    'total_tasks': metricSums['total_tasks']!.toInt(),
    'completed_tasks': metricSums['completed_tasks']!.toInt(),
    'pending_tasks': metricSums['pending_tasks']!.toInt(),
    'in_progress_tasks': metricSums['in_progress_tasks']!.toInt(),
    'monthly_income': metricSums['monthly_income']!,
    'active_clients': metricSums['active_clients']!.toInt(),
    'completion_rate': metricSums['completion_rate']!,
    'average_task_time': metricSums['average_task_time']!,
    'client_satisfaction': metricSums['client_satisfaction']!,
    'productivity_index': metricSums['productivity_index']!,
    'productive_employees': metricSums['productive_employees']!.toInt(),
    'total_tasks_completed': metricSums['total_tasks_completed']!.toInt(),
  };
}
}
