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
  @override
  Future<Map<String, dynamic>> getStatsForPeriod(DateTimeRange dateRange) async {
    try {
      final snapshot = await _firestore.collection('statistics')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
          .get();

      // Agregación por suma de campos numéricos comunes
      final aggregated = <String, double>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // el documento puede contener 'value' y 'metadata' o un map directo
        if (data.containsKey('metadata') && data['metadata'] is Map) {
          final meta = Map<String, dynamic>.from(data['metadata']);
          meta.forEach((k, v) {
            if (v is num) {
              aggregated[k] = (aggregated[k] ?? 0) + v.toDouble();
            } else if (v is String) {
              final parsed = double.tryParse(v) ?? 0.0;
              aggregated[k] = (aggregated[k] ?? 0) + parsed;
            }
          });
        } else {
          // si no hay metadata, escanear llaves numéricas del doc.data()
          data.forEach((k, v) {
            if (v is num) {
              aggregated[k] = (aggregated[k] ?? 0) + v.toDouble();
            } else if (v is String) {
              final parsed = double.tryParse(v) ?? 0.0;
              aggregated[k] = (aggregated[k] ?? 0) + parsed;
            }
          });
        }
      }

      // Normalizar salida: crear un mapa con llaves esperadas
      final Map<String, dynamic> out = {};

      // Campos por defecto con cast apropiado
      out['total_tasks'] = (aggregated['total_tasks'] ?? 0).toInt();
      out['completed_tasks'] = (aggregated['completed_tasks'] ?? 0).toInt();
      out['pending_tasks'] = (aggregated['pending_tasks'] ?? 0).toInt();
      out['in_progress_tasks'] = (aggregated['in_progress_tasks'] ?? 0).toInt();
      out['monthly_income'] = (aggregated['monthly_income'] ?? aggregated['total_income'] ?? 0.0).toDouble();
      out['active_clients'] = (aggregated['active_clients'] ?? 0).toInt();
      out['productive_employees'] = (aggregated['productive_employees'] ?? 0).toInt();
      out['total_tasks_completed'] = (aggregated['total_tasks_completed'] ?? aggregated['completed_tasks'] ?? 0).toInt();
      // ratios: completion_rate si posible
      final totalTasks = (out['total_tasks'] as int);
      final completed = (out['completed_tasks'] as int);
      out['completion_rate'] = totalTasks > 0 ? (completed / totalTasks) * 100.0 : 0.0;
      // average_task_time si existe suma y count
      if (aggregated.containsKey('average_task_time') && aggregated.containsKey('avg_count')) {
        final avgSum = aggregated['average_task_time'] ?? 0.0;
        final cnt = aggregated['avg_count'] ?? 1.0;
        out['average_task_time'] = cnt > 0 ? (avgSum / cnt) : 0.0;
      } else if (aggregated.containsKey('average_task_time')) {
        out['average_task_time'] = aggregated['average_task_time'] ?? 0.0;
      } else {
        out['average_task_time'] = 0.0;
      }
      // client satisfaction if exists
      out['client_satisfaction'] = (aggregated['client_satisfaction'] ?? 0.0).toDouble();
      // productivity index
      out['productivity_index'] = (aggregated['productivity_index'] ?? 0.0).toDouble();

      return out;
    } catch (e) {
      throw Exception('Error getStatsForPeriod: $e');
    }
  }
}
