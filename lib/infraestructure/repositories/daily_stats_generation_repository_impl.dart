// lib/infraestructure/repositories/daily_stats_generation_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/repositories/daily_stats_generation_repository.dart';

import '../../domain/entities/enities.dart';

class DailyStatsGenerationRepositoryImpl implements DailyStatsGenerationRepository {
  final FirebaseFirestore _firestore;
  
  static const List<String> _requiredMetrics = [
    'total_tasks',
    'completed_tasks', 
    'pending_tasks',
    'in_progress_tasks',
    'monthly_income',
    'active_clients',
    'completion_rate',
    'average_task_time',
    'client_satisfaction',
    'productivity_index',
    'productive_employees',
    'total_tasks_completed',
  ];

  DailyStatsGenerationRepositoryImpl(this._firestore);

  @override
  Future<bool> needsDailyGeneration(DateTime date) async {
    final missingMetrics = await getMissingMetricsForDate(date);
    return missingMetrics.isNotEmpty;
  }

  @override
  Future<List<String>> getMissingMetricsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final snapshot = await _firestore.collection('statistics')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

      final existingMetrics = snapshot.docs
          .map((doc) => doc.data()['metric'] as String?)
          .where((metric) => metric != null)
          .map((metric) => metric!)
          .toSet();

      return _requiredMetrics.where((metric) => !existingMetrics.contains(metric)).toList();
    } catch (e) {
      print('Error getting missing metrics: $e');
      return _requiredMetrics; // Si hay error, asumimos que faltan todos
    }
  }

  @override
  Future<void> generateDailyStatistics(DateTime date) async {
    final missingMetrics = await getMissingMetricsForDate(date);
    
    if (missingMetrics.isEmpty) {
      print('No missing metrics for $date');
      return;
    }

    print('Generating ${missingMetrics.length} metrics for $date');
    
    // En una implementación real, aquí llamarías al servicio para calcular las métricas
    // Por ahora, generamos valores placeholder
    for (final metric in missingMetrics) {
      final value = _getDefaultValueForMetric(metric);
      await saveDailyMetric(_createStatisticEntity(metric, value, date));
    }

    await updateLastGenerationDate(date);
  }

  @override
  Future<void> saveDailyMetric(StatisticEntity statistic) async {
    try {
      await _firestore.collection('statistics')
        .doc(statistic.statisticID) // Usamos el statisticID como ID del documento
        .set(statistic.toFirestore());
    } catch (e) {
      print('Error saving daily metric: $e');
      rethrow;
    }
  }

  @override
  Future<DateTime?> getLastGenerationDate() async {
    try {
      final doc = await _firestore.collection('app_config')
        .doc('daily_stats_generation')
        .get();
      
      if (doc.exists) {
        final data = doc.data();
        return (data?['last_generation_date'] as Timestamp?)?.toDate();
      }
      return null;
    } catch (e) {
      print('Error getting last generation date: $e');
      return null;
    }
  }

  @override
  Future<void> updateLastGenerationDate(DateTime date) async {
    try {
      await _firestore.collection('app_config')
        .doc('daily_stats_generation')
        .set({
          'last_generation_date': Timestamp.fromDate(date),
          'updated_at': Timestamp.now(),
        });
    } catch (e) {
      print('Error updating last generation date: $e');
      rethrow;
    }
  }

  // Helpers
  double _getDefaultValueForMetric(String metric) {
    switch (metric) {
      case 'total_tasks': return 0.0;
      case 'completed_tasks': return 0.0;
      case 'pending_tasks': return 0.0;
      case 'in_progress_tasks': return 0.0;
      case 'monthly_income': return 0.0;
      case 'active_clients': return 0.0;
      case 'completion_rate': return 0.0;
      case 'average_task_time': return 0.0;
      case 'client_satisfaction': return 0.0;
      case 'productivity_index': return 0.0;
      case 'productive_employees': return 0.0;
      case 'total_tasks_completed': return 0.0;
      default: return 0.0;
    }
  }

  StatisticEntity _createStatisticEntity(String metric, double value, DateTime date) {
    final statisticId = 'stats_${date.year}_${date.month}_${date.day}_$metric';
    
    return StatisticEntity(
      statisticID: statisticId,
      metric: metric,
      value: value,
      date: date
    );
  }
}