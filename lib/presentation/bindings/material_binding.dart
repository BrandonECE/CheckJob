// lib/presentation/bindings/material_binding.dart
import 'package:check_job/infraestructure/repositories/material_repository_impl.dart';
import 'package:check_job/infraestructure/services/material_service_impl.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/material/material_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:check_job/domain/services/material_service.dart';
import 'package:check_job/domain/repositories/material_repository.dart';

class MaterialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaterialService>(() => MaterialServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<MaterialRepository>(() => MaterialRepositoryImpl(
          materialService: Get.find<MaterialService>(),
        ));
    Get.lazyPut<MaterialController>(() => MaterialController(
          materialRepository: Get.find<MaterialRepository>(),
          adminController: Get.find<AdminController>(),
        ));
  }
}