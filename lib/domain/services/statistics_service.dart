// lib/domain/services/statistics_service.dart
import 'package:flutter/material.dart' show DateTimeRange;

abstract class StatisticService {
  /// Obtiene un mapa de métricas del dashboard para el periodo actual (sin parámetros).
  Future<Map<String, dynamic>> getDashboardStats();

  /// Obtiene las métricas del dashboard para un rango (start..end).
  Future<Map<String, dynamic>> getDashboardStatsForRange(DateTimeRange range);

  /// Métricas de tareas en rango
  Future<Map<String, dynamic>> getTaskStatistics(DateTimeRange range);

  /// Métricas de facturación en rango
  Future<Map<String, dynamic>> getBillingStatistics(DateTimeRange range);

  /// Métricas de clientes en rango
  Future<Map<String, dynamic>> getClientStatistics(DateTimeRange range);

  /// Métricas de productividad en rango
  Future<Map<String, dynamic>> getProductivityStatistics(DateTimeRange range);

  /// Generar estadísticas mensuales y guardarlas (opcional)
  Future<void> generateMonthlyStatistics();
}
