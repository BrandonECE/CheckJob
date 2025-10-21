// lib/domain/services/notification_service.dart
import 'package:check_job/domain/entities/notification_entity.dart';

abstract class NotificationService {
  Stream<List<NotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String notificationID);
  Future<void> deleteNotification(String notificationID);
  Future<void> createNotification(NotificationEntity notification); 
}