// lib/domain/repositories/notification_repository.dart
import 'package:check_job/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String notificationID);
  Future<void> deleteNotification(String notificationID);
  Future<void> createNotification(NotificationEntity notification); 
}