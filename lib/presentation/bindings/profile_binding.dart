// lib/presentation/bindings/profile_binding.dart
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/infraestructure/repositories/task_repository_impl.dart';
import 'package:check_job/infraestructure/repositories/client_repository_imp.dart';
import 'package:check_job/infraestructure/services/task_service_impl.dart';
import 'package:check_job/infraestructure/services/client_service_impl.dart';
import 'package:check_job/presentation/controllers/profile/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/services/task_service.dart';
import 'package:check_job/domain/services/client_service.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    // Servicios
    Get.lazyPut<TaskService>(
      () => TaskServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );
    
    Get.lazyPut<ClientService>(
      () => ClientServiceImpl(firestore: Get.find<FirebaseFirestore>()),
    );

    // Repositorios
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(taskService: Get.find<TaskService>()),
    );

    Get.lazyPut<ClientRepository>(
      () => ClientRepositoryImpl(clientService: Get.find<ClientService>()),
    );

    // Controller
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        taskRepository: Get.find<TaskRepository>(),
        clientRepository: Get.find<ClientRepository>(),
      ),
    );
  }
}