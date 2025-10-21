import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/services/invoice_service.dart';
import 'package:check_job/infraestructure/repositories/invoice_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/notification_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/task_repository_impl.dart';
import 'package:check_job/infraestructure/services/employee_service_impl.dart';
import 'package:check_job/infraestructure/services/invoice_service_impl.dart';
import 'package:check_job/infraestructure/services/notification_service_impl.dart';
import 'package:check_job/infraestructure/services/task_service_impl.dart';
import 'package:check_job/presentation/controllers/task/user_task_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:check_job/domain/services/task_service.dart';
import 'package:check_job/domain/services/notification_service.dart';
import 'package:check_job/domain/services/employee_service.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/notification_repository.dart';

class UserTaskBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<TaskService>(() => TaskServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<NotificationService>(() => NotificationServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<EmployeeService>(() => EmployeeServiceImpl(
      firestore: Get.find<FirebaseFirestore>(),
          storage: Get.find<FirebaseStorage>(),
        ));

    // Repositories
    Get.lazyPut<TaskRepository>(() => TaskRepositoryImpl(
          taskService: Get.find<TaskService>(),
        ));
    Get.lazyPut<NotificationRepository>(() => NotificationRepositoryImpl(
          notificationService: Get.find<NotificationService>(),
        ));

       Get.lazyPut<InvoiceService>(() => InvoiceServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepositoryImpl(
          invoiceService: Get.find<InvoiceService>(),
        ));

    // Controller
    Get.lazyPut<UserTaskController>(() => UserTaskController(
          taskRepository: Get.find<TaskRepository>(),
          notificationRepository: Get.find<NotificationRepository>(),
          employeeService: Get.find<EmployeeService>(),
          invoiceRepository: Get.find<InvoiceRepository>()
        ));
  }
}