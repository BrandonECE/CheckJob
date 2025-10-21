// lib/presentation/bindings/notification_binding.dart
import 'package:check_job/infraestructure/repositories/notification_repository_impl.dart';
import 'package:check_job/infraestructure/services/notification_service_impl.dart';
import 'package:check_job/presentation/controllers/notification/notification_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:check_job/domain/services/notification_service.dart';
import 'package:check_job/domain/repositories/notification_repository.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationService>(() => NotificationServiceImpl(
          firestore: Get.find<FirebaseFirestore>(),
        ));
    Get.lazyPut<NotificationRepository>(() => NotificationRepositoryImpl(
          notificationService: Get.find<NotificationService>(),
        ));
    Get.lazyPut<NotificationController>(() => NotificationController(
          notificationRepository: Get.find<NotificationRepository>(),
        ));
  }
}