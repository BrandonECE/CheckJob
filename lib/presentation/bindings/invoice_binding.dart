// lib/presentation/bindings/invoice_binding.dart

import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/services/invoice_service.dart';
import 'package:check_job/infraestructure/repositories/invoice_repository_impl.dart';
import 'package:check_job/infraestructure/services/invoice_service_impl.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/invoice/invoice_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceService>(() => InvoiceServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepositoryImpl(
          invoiceService: Get.find<InvoiceService>(),
        ));
    Get.lazyPut<InvoiceController>(() => InvoiceController(
          invoiceRepository: Get.find<InvoiceRepository>(),
          adminController: Get.find<AdminController>(),
        ));
  }
}