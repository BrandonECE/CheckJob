// lib/presentation/controllers/notification_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:check_job/domain/entities/notification_entity.dart';
import 'package:check_job/domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository;
  StreamSubscription? _notificationSubscription;

  NotificationController({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt notificaitonsCount = 0.obs;

  @override
  void onInit() {
    _loadNotifications();
    super.onInit();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
    _notificationSubscription = _notificationRepository.getNotifications().listen((notifs) {
      notifications.assignAll(notifs);
      notificaitonsCount.value = notifs.where((element) => element.read == false).length;
      isLoading.value = false;
    });
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron marcar todas como leídas');
    }
  }

  Future<void> markAsRead(String notificationID) async {
    try {
      await _notificationRepository.markAsRead(notificationID);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo marcar como leída');
    }
  }

  Future<void> deleteNotification(String notificationID) async {
    try {
      await _notificationRepository.deleteNotification(notificationID);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar la notificación');
    }
  }

  // Método para ser llamado cuando el usuario sale de la pantalla
  void onPageExited() {
    markAllAsRead();
  }
}