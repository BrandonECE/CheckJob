// lib/presentation/bindings/global_binding.dart
import 'package:check_job/infraestructure/repositories/auth_repository_impl.dart';
import 'package:check_job/infraestructure/services/auth_service_impl.dart';
import 'package:check_job/presentation/controllers/connectivity/connectivity_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/auth_service.dart';
import 'package:check_job/domain/repositories/auth_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/admin/admin_login_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Dependencias de Firebase: pueden ser lazy
    Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);
    Get.lazyPut(() => FirebaseStorage.instance, fenix: true); // Agregar esto
    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance, fenix: true);
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance, fenix: true);

    // Services que dependen de Firebase
    Get.put<AuthService>( AuthServiceImpl( firebaseAuth: Get.find<FirebaseAuth>(), firestore: Get.find<FirebaseFirestore>(), ), );

    Get.put<AuthRepository>( AuthRepositoryImpl(authService: Get.find<AuthService>()), );

    // Controlador principal que se comparte entre pantallas (estado persistente)
    Get.put<AdminController>( AdminController(authRepository: Get.find<AuthRepository>()), );
    // Controlador específico del login (también persistente)
    Get.put<AdminLoginController>( AdminLoginController(adminController: Get.find<AdminController>()), );
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
  }
}
