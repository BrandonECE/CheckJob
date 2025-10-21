// lib/presentation/bindings/report_binding.dart
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/report_service.dart';
import 'package:check_job/domain/repositories/report_repository.dart';
import 'package:check_job/infraestructure/services/report_service_impl.dart';
import 'package:check_job/infraestructure/repositories/report_repository_impl.dart';
import 'package:check_job/presentation/controllers/report/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    // Servicio



    Get.lazyPut<ReportService>(() => ReportServiceImpl(
      firestore: Get.find<FirebaseFirestore>(),
    ));
    
    // Repositorio
    Get.lazyPut<ReportRepository>(() => ReportRepositoryImpl(
      reportService: Get.find<ReportService>(),
    ));
    
    // Controlador
    Get.lazyPut<ReportController>(() => ReportController(
      adminController: Get.find<AdminController>(),
      reportRepository: Get.find<ReportRepository>(),
    ));
  }
}

