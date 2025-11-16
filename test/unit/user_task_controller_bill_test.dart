import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:check_job/domain/entities/invoice_entity.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/notification_repository.dart';
import 'package:check_job/domain/services/employee_service.dart';
import 'package:check_job/presentation/controllers/task/user_task_controller.dart';

// Mocks
class MockInvoiceRepository extends Mock implements InvoiceRepository {}
class MockTaskRepository extends Mock implements TaskRepository {}
class MockNotificationRepository extends Mock implements NotificationRepository {}
class MockEmployeeService extends Mock implements EmployeeService {}

void main() {
  late MockInvoiceRepository mockInvoiceRepo;
  late MockTaskRepository mockTaskRepo;
  late MockNotificationRepository mockNotificationRepo;
  late MockEmployeeService mockEmployeeService;
  late UserTaskController controller;

  // Datos de prueba (rellenados)
  final paidInvoice = InvoiceEntity(
    invoicesID: 'inv_paid_001',
    taskID: 'task123',
    clientName: 'Juan Pérez',
    clientID: 'client_001',
    amount: 1200.50,
    status: 'paid',
    dueDate: Timestamp.fromDate(DateTime.utc(2025, 10, 1)),
    createdAt: Timestamp.fromDate(DateTime.utc(2025, 9, 1)),
  );

  final unpaidInvoice = InvoiceEntity(
    invoicesID: 'inv_pending_001',
    taskID: 'task123',
    clientName: 'Juan Pérez',
    clientID: 'client_001',
    amount: 1200.50,
    status: 'pending',
    dueDate: Timestamp.fromDate(DateTime.utc(2025, 11, 1)),
    createdAt: Timestamp.fromDate(DateTime.utc(2025, 9, 15)),
  );

  final otherPaidInvoice = InvoiceEntity(
    invoicesID: 'inv_paid_002',
    taskID: 'task321',
    clientName: 'María López',
    clientID: 'client_002',
    amount: 800.00,
    status: 'paid',
    dueDate: Timestamp.fromDate(DateTime.utc(2025, 8, 1)),
    createdAt: Timestamp.fromDate(DateTime.utc(2025, 7, 10)),
  );

  setUp(() {
    mockInvoiceRepo = MockInvoiceRepository();
    mockTaskRepo = MockTaskRepository();
    mockNotificationRepo = MockNotificationRepository();
    mockEmployeeService = MockEmployeeService();

    controller = UserTaskController(
      taskRepository: mockTaskRepo,
      notificationRepository: mockNotificationRepo,
      employeeService: mockEmployeeService,
      invoiceRepository: mockInvoiceRepo,
    );
  });

  test('billWasPaid devuelve true si existe factura "paid" para taskId', () async {
    when(() => mockInvoiceRepo.getInvoicesOnce())
        .thenAnswer((_) async => [paidInvoice, otherPaidInvoice]);

    final result = await controller.billWasPaid('task123');

    expect(result, isTrue);
    verify(() => mockInvoiceRepo.getInvoicesOnce()).called(1);
  });

  test('billWasPaid devuelve false si no hay factura "paid" para taskId', () async {
    when(() => mockInvoiceRepo.getInvoicesOnce())
        .thenAnswer((_) async => [unpaidInvoice, otherPaidInvoice]);

    final result = await controller.billWasPaid('task123');

    expect(result, isFalse);
    verify(() => mockInvoiceRepo.getInvoicesOnce()).called(1);
  });
}
