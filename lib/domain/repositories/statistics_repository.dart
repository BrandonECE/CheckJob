// lib/domain/repositories/statistics_repository.dart
import 'package:flutter/material.dart' show DateTimeRange;

import '../entities/enities.dart';

/// Repositorio para acceder a la colección 'statistics' y obtener agregados.
/// Implementación concreta en infraestructure/repositories/statistic_repository_impl.dart
abstract class StatisticRepository {
  /// Devuelve un Stream de StatisticEntity (opcional - no usado en controller actual)
  Stream<List<StatisticEntity>> getStatistics();

  /// Obtener lista una vez
  Future<List<StatisticEntity>> getStatisticsOnce();

  /// Obtener estadísticas por métrica
  Future<List<StatisticEntity>> getStatisticsByMetric(String metric);

  /// Obtener estadísticas por rango de fechas
  Future<List<StatisticEntity>> getStatisticsByDateRange(DateTime start, DateTime end);

  /// Obtener estadística por métrica y rango
  Future<List<StatisticEntity>> getStatisticsByMetricAndDateRange(String metric, DateTime start, DateTime end);

  /// Crear estadística (guardar doc)
  Future<void> createStatistic(StatisticEntity statistic);

  /// Obtener un mapa agregados de métricas para un rango (este método es clave para la UI)
  /// Devuelve un Map con llaves: 'total_tasks','completed_tasks','pending_tasks','in_progress_tasks',
  /// 'monthly_income','active_clients','completion_rate','average_task_time','client_satisfaction','productivity_index',...
  Future<Map<String, dynamic>> getStatsForPeriod(DateTimeRange dateRange);
}
