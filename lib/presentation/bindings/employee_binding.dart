// lib/presentation/bindings/employee_binding.dart
import 'package:check_job/domain/repositories/employee_repository.dart';
import 'package:check_job/domain/services/employee_service.dart';
import 'package:check_job/infraestructure/repositories/employee_repository_impl.dart';
import 'package:check_job/infraestructure/services/employee_service_impl.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/employee/employee_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeService>(() => EmployeeServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
          storage: Get.find<FirebaseStorage>(),
        ));
    Get.lazyPut<EmployeeRepository>(() => EmployeeRepositoryImpl(
          employeeService: Get.find<EmployeeService>(),
        ));
    Get.lazyPut<EmployeeController>(() => EmployeeController(
          employeeRepository: Get.find<EmployeeRepository>(),
          adminController: Get.find<AdminController>(),
        ));
  }
}