// presentation/bindings/admin_task_binding.dart
import 'package:check_job/domain/repositories/employee_repository.dart';
import 'package:check_job/domain/services/employee_service.dart';
import 'package:check_job/domain/services/invoice_service.dart';
import 'package:check_job/domain/services/task_service.dart';
import 'package:check_job/infraestructure/repositories/employee_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/invoice_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/task_repository_impl.dart';
import 'package:check_job/infraestructure/services/employee_service_impl.dart';
import 'package:check_job/infraestructure/services/invoice_service_impl.dart';
import 'package:check_job/infraestructure/services/task_service_impl.dart';
import 'package:check_job/presentation/controllers/task/admin_task_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/repositories/material_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';

class AdminTaskBinding implements Bindings {
  @override
  void dependencies() {


//  final AdminTaskController _taskController = Get.find<AdminTaskController>();
//   final ClientController _clientController = Get.find<ClientController>();
//   final EmployeeController _employeeController = Get.find<EmployeeController>();
//   final MaterialController _materialController = Get.find<MaterialController>();

    Get.lazyPut<TaskService>(() => TaskServiceImpl( firestore: Get.find<FirebaseFirestore>(), ));
    Get.lazyPut<TaskRepository>(() => TaskRepositoryImpl( taskService: Get.find<TaskService>(), ));
    
    Get.lazyPut<InvoiceService>(() => InvoiceServiceImpl( firestore: Get.find<FirebaseFirestore>(), ));
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepositoryImpl( invoiceService: Get.find<InvoiceService>(), ));

    Get.lazyPut<EmployeeService>(() => EmployeeServiceImpl( firestore: Get.find<FirebaseFirestore>(), storage: Get.find<FirebaseStorage>(), ));
    Get.lazyPut<EmployeeRepository>(() => EmployeeRepositoryImpl( employeeService: Get.find<EmployeeService>(), ));

    Get.lazyPut<AdminTaskController>(() => AdminTaskController(
      taskRepository: Get.find<TaskRepository>(),
      invoiceRepository: Get.find<InvoiceRepository>(),
      materialRepository: Get.find<MaterialRepository>(),
      adminController: Get.find<AdminController>(),
      employeeRepository: Get.find<EmployeeRepository>()
    ));
  }
}