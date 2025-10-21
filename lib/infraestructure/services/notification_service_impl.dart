// lib/data/services/notification_service_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/notification_service.dart';
import 'package:check_job/domain/entities/notification_entity.dart';

class NotificationServiceImpl implements NotificationService {
  final FirebaseFirestore _firestore;

  NotificationServiceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    try {
      return _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener notificaciones: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NotificationEntity.fromFirestore(doc.data()))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error al crear stream de notificaciones: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get(GetOptions(source: Source.server));

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      return Future.error('Error al marcar todas como leídas: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationID) async {
    try {
      await _firestore.collection('notifications').doc(notificationID).update({
        'read': true,
      });
    } catch (e) {
      return Future.error('Error al marcar como leída: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationID) async {
    try {
      await _firestore.collection('notifications').doc(notificationID).delete();
    } catch (e) {
      return Future.error('Error al eliminar notificación: $e');
    }
  }

@override
  Future<void> createNotification(NotificationEntity notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.notificationID)
          .set(notification.toMap());
    } catch (e) {
      return Future.error('Error al crear notificación: $e');
    }
  }
}
