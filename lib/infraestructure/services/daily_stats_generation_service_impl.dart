// lib/infraestructure/services/daily_stats_generation_service_impl.dart
import 'package:check_job/domain/services/daily_stats_generation_service.dart';
import 'package:check_job/domain/repositories/daily_stats_generation_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyStatsGenerationServiceImpl implements DailyStatsGenerationService {
  final DailyStatsGenerationRepository _repository;
  final FirebaseFirestore _firestore;

  DailyStatsGenerationServiceImpl(this._repository, this._firestore);

  @override
  Future<bool> checkAndGenerateDailyStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final needsGeneration = await _repository.needsDailyGeneration(today);
      
      if (needsGeneration) {
        print('Daily stats generation needed for $today');
        await _repository.generateDailyStatistics(today);
        return true;
      } else {
        print('Daily stats already generated for $today');
        return false;
      }
    } catch (e) {
      print('Error in checkAndGenerateDailyStats: $e');
      return false;
    }
  }

  @override
  Future<void> forceGenerateDailyStats(DateTime date) async {
    await _repository.generateDailyStatistics(date);
  }

  @override
  Future<Map<String, dynamic>> calculateDailyMetrics(DateTime date) async {
    // Implementación real que calcula métricas desde los datos de Firestore
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Obtener tareas del día
      final tasksSnapshot = await _firestore.collection('tasks')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

      final tasks = tasksSnapshot.docs.map((doc) => doc.data()).toList();

      // Obtener facturas del día
      final invoicesSnapshot = await _firestore.collection('invoices')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

      final invoices = invoicesSnapshot.docs.map((doc) => doc.data()).toList();

      // Obtener clientes activos
      final clientsSnapshot = await _firestore.collection('clients').get();
      final clients = clientsSnapshot.docs.map((doc) => doc.data()).toList();

      // Obtener empleados
      final employeesSnapshot = await _firestore.collection('employees').get();
      final employees = employeesSnapshot.docs.map((doc) => doc.data()).toList();

      // Calcular métricas (simplificado - expandir según necesites)
      return _calculateMetricsFromData(tasks, invoices, clients, employees, date);
    } catch (e) {
      print('Error calculating daily metrics: $e');
      return {};
    }
  }

  @override
  Future<bool> isGenerationNeeded(DateTime date) async {
    return await _repository.needsDailyGeneration(date);
  }

  Map<String, dynamic> _calculateMetricsFromData(
    List<Map<String, dynamic>> tasks,
    List<Map<String, dynamic>> invoices,
    List<Map<String, dynamic>> clients,
    List<Map<String, dynamic>> employees,
    DateTime date,
  ) {
    // Implementa aquí los cálculos reales basados en tus datos
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => 
      (task['status']?.toString().toLowerCase().contains('completed') ?? false)
    ).length;

    final dailyIncome = invoices.fold<double>(0.0, (sum, invoice) => 
      sum + ((invoice['amount'] ?? 0.0) as num).toDouble()
    );

    final activeClients = clients.where((client) => 
      client['isActive'] == true
    ).length;

    return {
      'total_tasks': totalTasks.toDouble(),
      'completed_tasks': completedTasks.toDouble(),
      'pending_tasks': (totalTasks - completedTasks).toDouble(),
      'in_progress_tasks': 0.0, // Calcular según tu lógica
      'monthly_income': dailyIncome,
      'active_clients': activeClients.toDouble(),
      'completion_rate': totalTasks > 0 ? (completedTasks / totalTasks * 100.0) : 0.0,
      'average_task_time': 2.5, // Calcular basado en tus datos
      'client_satisfaction': 85.0, // Calcular basado en feedback
      'productivity_index': 75.0, // Calcular basado en tus métricas
      'productive_employees': employees.where((e) => e['isActive'] == true).length.toDouble(),
      'total_tasks_completed': completedTasks.toDouble(),
    };
  }
}