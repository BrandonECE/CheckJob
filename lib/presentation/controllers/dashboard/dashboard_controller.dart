// lib/presentation/controllers/dashboard_controller.dart
import 'dart:async';

import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/entities/invoice_entity.dart';

class DashboardController extends GetxController {
  final TaskRepository _taskRepository;
  final ClientRepository _clientRepository;
  final InvoiceRepository _invoiceRepository;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _clientsSubscription;
  StreamSubscription? _invoicesSubscription;

  DashboardController({
    required TaskRepository taskRepository,
    required ClientRepository clientRepository,
    required InvoiceRepository invoiceRepository,
  }) : _taskRepository = taskRepository,
       _clientRepository = clientRepository,
       _invoiceRepository = invoiceRepository;

  final RxList<TaskEntity> allTasks = <TaskEntity>[].obs;
  final RxList<ClientEntity> allClients = <ClientEntity>[].obs;
  final RxList<InvoiceEntity> allInvoices = <InvoiceEntity>[].obs;
  final RxBool isLoading = false.obs;

  // Estadísticas
  final RxInt pendingTasksCount = 0.obs;
  final RxInt completedTasksCount = 0.obs;
  final RxInt activeClientsCount = 0.obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxList<TaskEntity> recentActivities = <TaskEntity>[].obs;

  @override
  void onInit() {
    _loadDashboardData();
    super.onInit();
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _clientsSubscription?.cancel();
    _invoicesSubscription?.cancel();
    super.onClose();
  }

   Future<void>  _loadDashboardData() async {
    isLoading.value = true;
    // Cargar tareas
    _tasksSubscription = _taskRepository.getTasks().listen((tasks) {
      allTasks.assignAll(tasks);
      _calculateTaskStats();
      _loadRecentActivities();
    });

    // Cargar clientes
    _clientsSubscription = _clientRepository.getClients().listen((clients) {
      allClients.assignAll(clients);
      _calculateActiveClients();
    });

    // Cargar facturas
    _invoicesSubscription = _invoiceRepository.getInvoices().listen((invoices) {
      allInvoices.assignAll(invoices);
      _calculateMonthlyIncome();
    });
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;

  }

  void _calculateTaskStats() {
    pendingTasksCount.value = allTasks
        .where(
          (task) =>
              task.status.toLowerCase().contains('pending') ||
              task.status.toLowerCase().contains('in_progress'),
        )
        .length;

    completedTasksCount.value = allTasks
        .where((task) => task.status.toLowerCase().contains('completed'))
        .length;

  }

  void _calculateActiveClients() {
    // Un cliente está activo si tiene al menos una tarea pendiente o en progreso
    activeClientsCount.value = allClients.where((client) {
      return client.tasks!.any(
        (task) =>
            task.status.toLowerCase().contains('pending') ||
            task.status.toLowerCase().contains('in_progress'),
      );
    }).length;
  }

  void _calculateMonthlyIncome() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double total = 0;

    for (final invoice in allInvoices) {
      final invoiceDate = invoice.createdAt.toDate();
      if (invoiceDate.isAfter(firstDayOfMonth) &&
          invoiceDate.isBefore(lastDayOfMonth) &&
          invoice.status == 'paid') {
        total += invoice.amount;
      }
    }

    monthlyIncome.value = total;
  }

  void _loadRecentActivities() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

    recentActivities.assignAll(
      allTasks
          .where((task) => task.createdAt.toDate().isAfter(oneWeekAgo))
          .toList(),
    );

    // Ordenar por fecha más reciente primero
    recentActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;

    try {
      await Future.delayed(Duration(milliseconds: 700));
      final tasks = await _taskRepository.getTasksOnce();
      final clients = await _clientRepository.getClientsOnce();
      final invoices = await _invoiceRepository.getInvoicesOnce();

      allTasks.assignAll(tasks);
      allClients.assignAll(clients);
      allInvoices.assignAll(invoices);

      _calculateTaskStats();
      _calculateActiveClients();
      _calculateMonthlyIncome();
      _loadRecentActivities();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
