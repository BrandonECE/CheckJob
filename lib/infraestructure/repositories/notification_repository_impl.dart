// lib/data/repositories/notification_repository_impl.dart
import 'package:check_job/domain/repositories/notification_repository.dart';
import 'package:check_job/domain/services/notification_service.dart';
import 'package:check_job/domain/entities/notification_entity.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepositoryImpl({required NotificationService notificationService})
      : _notificationService = notificationService;

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    try {
      return _notificationService.getNotifications();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener notificaciones: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      return await _notificationService.markAllAsRead();
    } catch (e) {
      return Future.error('Error en repositorio al marcar todas como leídas: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationID) async {
    try {
      return await _notificationService.markAsRead(notificationID);
    } catch (e) {
      return Future.error('Error en repositorio al marcar como leída: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationID) async {
    try {
      return await _notificationService.deleteNotification(notificationID);
    } catch (e) {
      return Future.error('Error en repositorio al eliminar notificación: $e');
    }
  }

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    try {
      return await _notificationService.createNotification(notification);
    } catch (e) {
      return Future.error('Error en repositorio al crear notificación: $e');
    }
  }
}