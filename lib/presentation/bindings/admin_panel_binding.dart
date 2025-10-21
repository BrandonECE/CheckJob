// lib/presentation/bindings/admin_panel_binding.dart
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/infraestructure/repositories/task_repository_impl.dart';
import 'package:check_job/infraestructure/services/task_service_impl.dart';
import 'package:check_job/presentation/controllers/admin/admin_panel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/services/task_service.dart';

class AdminPanelBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskService>(
      () => TaskServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );
    
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(taskService: Get.find<TaskService>()),
    );

    Get.lazyPut<AdminPanelController>(
      () => AdminPanelController(
        taskRepository: Get.find<TaskRepository>(),
      ),
    );
  }
}