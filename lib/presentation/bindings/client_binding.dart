// lib/presentation/bindings/client_binding.dart
import 'package:check_job/infraestructure/repositories/client_repository_imp.dart';
import 'package:check_job/infraestructure/services/client_service_impl.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:check_job/domain/services/client_service.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/presentation/controllers/client/client_controller.dart';

class ClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientService>(() => ClientServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<ClientRepository>(() => ClientRepositoryImpl(
          clientService: Get.find<ClientService>(),
        ));
    Get.lazyPut<ClientController>(() => ClientController(
          clientRepository: Get.find<ClientRepository>(),
          adminController: Get.find<AdminController>(),
        ));
  }
}