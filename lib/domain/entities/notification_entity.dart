// lib/domain/entities/notification_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEntity {
  final String notificationID;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;

  NotificationEntity({
    required this.notificationID,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationEntity.fromFirestore(Map<String, dynamic> data) {
    return NotificationEntity(
      notificationID: data['notificationID'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationID': notificationID,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationEntity copyWith({
    String? notificationID,
    String? title,
    String? body,
    String? type,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      notificationID: notificationID ?? this.notificationID,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}