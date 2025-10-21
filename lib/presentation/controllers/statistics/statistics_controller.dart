// lib/presentation/controllers/statistics/statistics_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/repositories/statistics_repository.dart';
import 'package:check_job/domain/services/statistics_service.dart';

class StatisticController extends GetxController {
  final StatisticRepository _statisticRepository;
  final StatisticService _statisticService;

  StatisticController({
    required StatisticRepository statisticRepository,
    required StatisticService statisticService,
  })  : _statisticRepository = statisticRepository,
        _statisticService = statisticService;

  // Estados
  final isLoading = false.obs;
  final dashboardStats = <String, dynamic>{}.obs; // stats para periodo seleccionado
  final previousDashboardStats = <String, dynamic>{}.obs; // stats del periodo anterior (para comparacion)
  final selectedTimeFilter = 'Hoy'.obs; // POR DEFECTO: Hoy
  final useStatisticsCollection = true.obs; // si true: usa colección 'statistics', si false: calcula desde tablas

  // Filtros de tiempo (UI)
  final List<String> timeFilters = ['Hoy', 'Semana', 'Mes', 'Trimestre', 'Año'];

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
  }

  Future<void> refreshStatistics() async {
    await loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    isLoading.value = true;

    // limpiar para evitar stale UI
    dashboardStats.clear();
    previousDashboardStats.clear();

    final currentRange = _rangeForFilter(selectedTimeFilter.value);
    final prevRange = _previousRangeForFilter(selectedTimeFilter.value);

    try {
      if (useStatisticsCollection.value) {
        // obtener mapas agregados desde "statistics"
        final Map<String, dynamic> current = await _statisticRepository.getStatsForPeriod(currentRange);
        final Map<String, dynamic> previous = await _statisticRepository.getStatsForPeriod(prevRange);

        dashboardStats.value = _normalizeStatsMap(current);
        previousDashboardStats.value = _normalizeStatsMap(previous);
      } else {
        // calcular en vivo desde tablas (service)
        final Map<String, dynamic> current = await _statisticService.getDashboardStatsForRange(currentRange);
        final Map<String, dynamic> previous = await _statisticService.getDashboardStatsForRange(prevRange);

        dashboardStats.value = _normalizeStatsMap(current);
        previousDashboardStats.value = _normalizeStatsMap(previous);
      }
    } catch (e) {
      _showError('Error al cargar estadísticas: ${e.toString()}');
      dashboardStats.value = _normalizeStatsMap(null);
      previousDashboardStats.value = _normalizeStatsMap(null);
    } finally {
      isLoading.value = false;
    }
  }

  void setTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
    loadDashboardStats();
  }

  // ====== Helpers de rango (usando DateTimeRange de report_entity.dart) ======
  DateTimeRange _rangeForFilter(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Hoy':
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case 'Semana':
        // asumimos semana inicia Lunes
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 6)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: start, end: end);
      case 'Mes':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case 'Trimestre':
        final q = ((now.month - 1) ~/ 3);
        final startMonth = q * 3 + 1;
        final start = DateTime(now.year, startMonth, 1);
        final end = DateTime(now.year, startMonth + 3, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case 'Año':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      default:
        final startDefault = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startDefault, end: now);
    }
  }

  DateTimeRange _previousRangeForFilter(String filter) {
    final current = _rangeForFilter(filter);
    final duration = current.end.difference(current.start.add(const Duration(seconds: 1)));
    final prevEnd = current.start.subtract(const Duration(seconds: 1));
    final prevStart = prevEnd.subtract(duration).add(const Duration(seconds: 1));
    return DateTimeRange(start: prevStart, end: prevEnd);
  }

  // ====== Normalización de mapas (garantizar llaves y tipos) ======
  Map<String, dynamic> _normalizeStatsMap(Map<String, dynamic>? raw) {
    final Map<String, dynamic> out = {
      'total_tasks': 0,
      'completed_tasks': 0,
      'pending_tasks': 0,
      'in_progress_tasks': 0,
      'monthly_income': 0.0,
      'active_clients': 0,
      'completion_rate': 0.0,
      'average_task_time': 0.0,
      'client_satisfaction': 0.0,
      'productivity_index': 0.0,
      'productive_employees': 0,
      'total_tasks_completed': 0,
    };
    if (raw == null) return out;
    raw.forEach((k, v) {
      if (out.containsKey(k)) {
        out[k] = v is num ? v : (double.tryParse(v.toString()) ?? v);
      } else {
        // ignoramos llaves desconocidas
      }
    });
    // asegurar tipos correctos para algunas llaves
    out['monthly_income'] = (out['monthly_income'] is num) ? (out['monthly_income'] as num).toDouble() : (double.tryParse(out['monthly_income'].toString()) ?? 0.0);
    out['completion_rate'] = (out['completion_rate'] is num) ? (out['completion_rate'] as num).toDouble() : (double.tryParse(out['completion_rate'].toString()) ?? 0.0);
    return out;
  }

  // ====== Getters para UI (valores y formatos) ======
  int get totalTasks => dashboardStats['total_tasks'] ?? 0;
  int get completedTasks => dashboardStats['completed_tasks'] ?? 0;
  int get pendingTasks => dashboardStats['pending_tasks'] ?? 0;
  int get inProgressTasks => dashboardStats['in_progress_tasks'] ?? 0;
  double get monthlyIncome => (dashboardStats['monthly_income'] ?? 0.0) is num ? (dashboardStats['monthly_income'] as num).toDouble() : 0.0;
  int get activeClients => dashboardStats['active_clients'] ?? 0;
  double get completionRate => (dashboardStats['completion_rate'] ?? 0.0) is num ? (dashboardStats['completion_rate'] as num).toDouble() : 0.0;
  double get averageTaskTime => (dashboardStats['average_task_time'] ?? 0.0) is num ? (dashboardStats['average_task_time'] as num).toDouble() : 0.0;
  double get clientSatisfaction => (dashboardStats['client_satisfaction'] ?? 0.0) is num ? (dashboardStats['client_satisfaction'] as num).toDouble() : 0.0;
  double get productivityIndex => (dashboardStats['productivity_index'] ?? 0.0) is num ? (dashboardStats['productivity_index'] as num).toDouble() : 0.0;

  String get formattedMonthlyIncome => '\$${monthlyIncome.toStringAsFixed(2)}';
  String get formattedCompletionRate => '${completionRate.toStringAsFixed(1)}%';
  String get formattedAverageTaskTime => '${averageTaskTime.toStringAsFixed(1)}h';
  String get formattedClientSatisfaction => '${clientSatisfaction.toStringAsFixed(1)}%';
  String get formattedProductivityIndex => '${productivityIndex.toStringAsFixed(1)}%';

  // ====== Comparación (texto y color) ======
  // metricKey es la llave en el mapa: 'completed_tasks', 'monthly_income', 'active_clients', 'productivity_index', etc.
  String comparisonTextForMetric(String metricKey) {
    final current = dashboardStats[metricKey];
    final previous = previousDashboardStats[metricKey];

    final curNum = (current is num) ? current.toDouble() : double.tryParse(current?.toString() ?? '0') ?? 0.0;
    final prevNum = (previous is num) ? previous.toDouble() : double.tryParse(previous?.toString() ?? '0') ?? 0.0;

    // Si prev = 0 -> no comparar, mostrar "0% vs (periodo anterior)"
    if (prevNum == 0) {
      return '0% vs período anterior';
    }

    final change = ((curNum - prevNum) / prevNum) * 100;
    final sign = change > 0 ? '+' : (change < 0 ? '' : '');

    // Formato: '+12.4% vs periodo anterior' o '-5.2% vs periodo anterior'
    final display = '${sign}${change.toStringAsFixed(1)}% vs periodo anterior';
    return display;
  }

  Color comparisonColorForMetric(String metricKey) {
    final current = dashboardStats[metricKey];
    final previous = previousDashboardStats[metricKey];

    final curNum = (current is num) ? current.toDouble() : double.tryParse(current?.toString() ?? '0') ?? 0.0;
    final prevNum = (previous is num) ? previous.toDouble() : double.tryParse(previous?.toString() ?? '0') ?? 0.0;

    if (prevNum == 0) {
      return Colors.grey; // neutro
    }

    final change = ((curNum - prevNum) / prevNum) * 100;
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  // ====== Utilities (snackbars) ======
  void _showError(String msg) {
    Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
  }
}
