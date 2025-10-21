// lib/infraestructure/services/statistic_service_impl.dart
import 'package:check_job/domain/services/statistics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show DateTimeRange;

class StatisticServiceImpl implements StatisticService {
  final FirebaseFirestore _firestore;

  StatisticServiceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentRange = DateTimeRange(start: currentMonthStart, end: now);
    return getDashboardStatsForRange(currentRange);
  }

  @override
  Future<Map<String, dynamic>> getDashboardStatsForRange(DateTimeRange range) async {
    // Llama a submétodos para obtener datos reales y luego combinar
    final tasks = await _getTasksData(range.start, range.end);
    final invoices = await _getInvoicesData(range.start, range.end);
    final clients = await _getClientsData();
    final employees = await _getEmployeesData();

    return _calculateDashboardMetrics(tasks, invoices, clients, employees);
  }

  @override
  Future<Map<String, dynamic>> getTaskStatistics(DateTimeRange range) async {
    final tasks = await _getTasksData(range.start, range.end);
    return _calculateTaskMetrics(tasks);
  }

  @override
  Future<Map<String, dynamic>> getBillingStatistics(DateTimeRange range) async {
    final invoices = await _getInvoicesData(range.start, range.end);
    return _calculateBillingMetrics(invoices);
  }

  @override
  Future<Map<String, dynamic>> getClientStatistics(DateTimeRange range) async {
    final clients = await _getClientsData();
    final tasks = await _getTasksData(range.start, range.end);
    return _calculateClientMetrics(clients, tasks);
  }

  @override
  Future<Map<String, dynamic>> getProductivityStatistics(DateTimeRange range) async {
    final tasks = await _getTasksData(range.start, range.end);
    final employees = await _getEmployeesData();
    return _calculateProductivityMetrics(tasks, employees);
  }

  @override
  Future<void> generateMonthlyStatistics() async {
    // ejemplo simple: crea docs en collection 'statistics' con metadata
    final now = DateTime.now();
    final monthRange = DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
    final dashboard = await getDashboardStatsForRange(monthRange);
    final id = 'stats_${now.year}_${now.month}_dashboard';
    final doc = {
      'metric': 'dashboard',
      'value': dashboard['productivity_index'] ?? 0.0,
      'date': Timestamp.fromDate(now),
      'metadata': dashboard,
    };
    await _firestore.collection('statistics').doc(id).set(doc);
  }

  // ----------------- Métodos privados para lectura -----------------
  Future<List<Map<String, dynamic>>> _getTasksData(DateTime start, DateTime end) async {
    try {
      final snap = await _firestore.collection('tasks').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end)).get(GetOptions(source: Source.server));
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getInvoicesData(DateTime start, DateTime end) async {
    try {
      final snap = await _firestore.collection('invoices').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end)).get(GetOptions(source: Source.server));
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getClientsData() async {
    try {
      final snap = await _firestore.collection('clients').get(GetOptions(source: Source.server));
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getEmployeesData() async {
    try {
      final snap = await _firestore.collection('employees').get(GetOptions(source: Source.server));
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // ----------------- Cálculos (copiados/mejorados de lo que ya tenías) -----------------
  Future<Map<String, dynamic>> _calculateDashboardMetrics(
    List<Map<String, dynamic>> tasks,
    List<Map<String, dynamic>> invoices,
    List<Map<String, dynamic>> clients,
    List<Map<String, dynamic>> employees,
  ) async {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('completed') || (t['status'] ?? '').toString().toLowerCase().contains('completado')).length;
    final pendingTasks = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('pending') || (t['status'] ?? '').toString().toLowerCase().contains('pendiente')).length;
    final inProgressTasks = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('in_progress') || (t['status'] ?? '').toString().toLowerCase().contains('en_progreso')).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100.0 : 0.0;

    final monthlyIncome = invoices.fold<double>(0.0, (sum, inv) => sum + ((inv['amount'] ?? 0.0) as num).toDouble());
    final activeClients = clients.where((c) => c['isActive'] == true).length;

    final productiveEmployees = employees.where((e) => e['isActive'] == true).length;
    final avgTasksPerEmployee = productiveEmployees > 0 ? (completedTasks / productiveEmployees) : 0.0;

    final averageTaskTime = _calculateAverageTaskTime(tasks);
    final clientSatisfaction = _calculateClientSatisfaction(tasks, invoices);
    final productivityIndex = _calculateProductivityIndex(completionRate, avgTasksPerEmployee, clientSatisfaction);

    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'in_progress_tasks': inProgressTasks,
      'monthly_income': monthlyIncome,
      'active_clients': activeClients,
      'completion_rate': completionRate,
      'average_task_time': averageTaskTime,
      'client_satisfaction': clientSatisfaction,
      'productivity_index': productivityIndex,
      'productive_employees': productiveEmployees,
      'total_tasks_completed': completedTasks,
    };
  }

  Map<String, dynamic> _calculateTaskMetrics(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return {'total': 0, 'completed': 0, 'pending': 0, 'in_progress': 0, 'completion_rate': 0.0, 'avg_completion_time': 0.0, 'status_distribution': {}};
    }
    final statusCount = <String, int>{};
    final completionTimes = <double>[];
    for (final task in tasks) {
      final status = (task['status'] ?? 'unknown').toString();
      statusCount[status] = (statusCount[status] ?? 0) + 1;
      if ((status.toLowerCase().contains('completed') || status.toLowerCase().contains('completado')) && task['createdAt'] != null && task['completedAt'] != null) {
        try {
          final createdAt = (task['createdAt'] as Timestamp).toDate();
          final completedAt = (task['completedAt'] as Timestamp).toDate();
          final hours = completedAt.difference(createdAt).inHours.toDouble();
          completionTimes.add(hours);
        } catch (_) {}
      }
    }
    final avgCompletionTime = completionTimes.isNotEmpty ? completionTimes.reduce((a, b) => a + b) / completionTimes.length : 0.0;
    return {
      'total': tasks.length,
      'completed': statusCount['completed'] ?? 0,
      'pending': statusCount['pending'] ?? 0,
      'in_progress': statusCount['in_progress'] ?? 0,
      'completion_rate': (statusCount['completed'] ?? 0) / tasks.length * 100,
      'avg_completion_time': avgCompletionTime,
      'status_distribution': statusCount,
    };
  }

  Map<String, dynamic> _calculateBillingMetrics(List<Map<String, dynamic>> invoices) {
    if (invoices.isEmpty) {
      return {'total_income': 0.0, 'paid_invoices': 0, 'pending_invoices': 0, 'overdue_invoices': 0, 'avg_invoice_amount': 0.0, 'payment_distribution': {}};
    }
    final now = DateTime.now();
    double totalIncome = 0.0;
    int paidInvoices = 0;
    int pendingInvoices = 0;
    int overdueInvoices = 0;
    final paymentDistribution = <String, int>{};

    for (final inv in invoices) {
      final amount = (inv['amount'] ?? 0.0) is num ? (inv['amount'] as num).toDouble() : double.tryParse(inv['amount']?.toString() ?? '0') ?? 0.0;
      final status = (inv['status'] ?? 'pending').toString();
      final dueDate = inv['dueDate'] != null ? (inv['dueDate'] as Timestamp).toDate() : null;

      totalIncome += amount;
      paymentDistribution[status] = (paymentDistribution[status] ?? 0) + 1;

      if (status.toLowerCase().contains('paid')) paidInvoices++;
      else {
        pendingInvoices++;
        if (dueDate != null && dueDate.isBefore(now)) overdueInvoices++;
      }
    }

    return {
      'total_income': totalIncome,
      'paid_invoices': paidInvoices,
      'pending_invoices': pendingInvoices,
      'overdue_invoices': overdueInvoices,
      'avg_invoice_amount': invoices.isNotEmpty ? totalIncome / invoices.length : 0.0,
      'payment_distribution': paymentDistribution,
    };
  }

  Map<String, dynamic> _calculateClientMetrics(List<Map<String, dynamic>> clients, List<Map<String, dynamic>> tasks) {
    final activeClients = clients.where((c) => c['isActive'] == true).length;
    final inactiveClients = clients.length - activeClients;
    final tasksPerClient = <String, int>{};
    for (final t in tasks) {
      final cid = t['clientID']?.toString();
      if (cid != null) tasksPerClient[cid] = (tasksPerClient[cid] ?? 0) + 1;
    }
    final avgTasksPerClient = tasksPerClient.isNotEmpty ? tasksPerClient.values.reduce((a, b) => a + b) / tasksPerClient.length : 0.0;
    return {
      'total_clients': clients.length,
      'active_clients': activeClients,
      'inactive_clients': inactiveClients,
      'activation_rate': clients.isNotEmpty ? (activeClients / clients.length) * 100 : 0.0,
      'avg_tasks_per_client': avgTasksPerClient,
      'tasks_per_client': tasksPerClient,
    };
  }

  Map<String, dynamic> _calculateProductivityMetrics(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> employees) {
    final productiveEmployees = employees.where((e) => e['isActive'] == true).length;
    if (productiveEmployees == 0) {
      return {'productive_employees': 0, 'tasks_per_employee': 0.0, 'completion_rate': 0.0, 'efficiency_score': 0.0};
    }
    final completedTasks = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('completed') || (t['status'] ?? '').toString().toLowerCase().contains('completado')).length;
    final tasksPerEmployee = completedTasks / productiveEmployees;
    final completionRate = tasks.isNotEmpty ? (completedTasks / tasks.length) * 100 : 0.0;
    final efficiencyScore = _calculateEfficiencyScore(tasks);
    return {
      'productive_employees': productiveEmployees,
      'tasks_per_employee': tasksPerEmployee,
      'completion_rate': completionRate,
      'efficiency_score': efficiencyScore,
      'total_tasks_completed': completedTasks,
    };
  }

  // ----- auxiliares -----
  double _calculateAverageTaskTime(List<Map<String, dynamic>> tasks) {
    final completed = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('completed') || (t['status'] ?? '').toString().toLowerCase().contains('completado')).toList();
    if (completed.isEmpty) return 2.5;
    double totalHours = 0.0;
    int count = 0;
    for (final t in completed) {
      try {
        if (t['createdAt'] != null && t['completedAt'] != null) {
          final c = (t['createdAt'] as Timestamp).toDate();
          final f = (t['completedAt'] as Timestamp).toDate();
          totalHours += f.difference(c).inHours.toDouble();
          count++;
        }
      } catch (_) {}
    }
    return count > 0 ? totalHours / count : 2.5;
  }

  double _calculateClientSatisfaction(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> invoices) {
    final completed = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('completed') || (t['status'] ?? '').toString().toLowerCase().contains('completado')).length;
    final paid = invoices.where((i) => (i['status'] ?? '').toString().toLowerCase().contains('paid')).length;
    final taskSatisfaction = tasks.isNotEmpty ? (completed / tasks.length) * 100 : 0.0;
    final paymentSatisfaction = invoices.isNotEmpty ? (paid / invoices.length) * 100 : 0.0;
    return (taskSatisfaction * 0.7 + paymentSatisfaction * 0.3);
  }

  double _calculateProductivityIndex(double completionRate, double tasksPerEmployee, double clientSatisfaction) {
    return (completionRate * 0.4 + tasksPerEmployee * 0.3 + clientSatisfaction * 0.3);
  }

  double _calculateEfficiencyScore(List<Map<String, dynamic>> tasks) {
    final completed = tasks.where((t) => (t['status'] ?? '').toString().toLowerCase().contains('completed') || (t['status'] ?? '').toString().toLowerCase().contains('completado')).toList();
    if (completed.isEmpty) return 0.0;
    double totalEfficiency = 0.0;
    int count = 0;
    for (final t in completed) {
      try {
        if (t['createdAt'] != null && t['completedAt'] != null) {
          final c = (t['createdAt'] as Timestamp).toDate();
          final f = (t['completedAt'] as Timestamp).toDate();
          final hours = f.difference(c).inHours.toDouble();
          final eff = hours > 0 ? 100 / hours : 100;
          totalEfficiency += eff;
          count++;
        }
      } catch (_) {}
    }
    return count > 0 ? totalEfficiency / count : 0.0;
  }
}
