// lib/presentation/bindings/dashboard_binding.dart
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/infraestructure/repositories/client_repository_imp.dart';
import 'package:check_job/infraestructure/repositories/invoice_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/task_repository_impl.dart';
import 'package:check_job/infraestructure/services/client_service_impl.dart';
import 'package:check_job/infraestructure/services/invoice_service_impl.dart';
import 'package:check_job/infraestructure/services/task_service_impl.dart';
import 'package:check_job/presentation/controllers/dashboard/dashboard_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/services/task_service.dart';
import 'package:check_job/domain/services/client_service.dart';
import 'package:check_job/domain/services/invoice_service.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskService>(
      () => TaskServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(taskService: Get.find<TaskService>()),
    );

    Get.lazyPut<ClientService>(
      () => ClientServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );
    Get.lazyPut<ClientRepository>(
      () => ClientRepositoryImpl(clientService: Get.find<ClientService>()),
    );

    Get.lazyPut<InvoiceService>(
      () => InvoiceServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );
    Get.lazyPut<InvoiceRepository>(
      () => InvoiceRepositoryImpl(invoiceService: Get.find<InvoiceService>()),
    );

    Get.lazyPut<DashboardController>(
      () => DashboardController(
        taskRepository: Get.find<TaskRepository>(),
        clientRepository: Get.find<ClientRepository>(),
        invoiceRepository: Get.find<InvoiceRepository>(),
      ),
    );
  }
}
