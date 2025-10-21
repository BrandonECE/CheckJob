// lib/presentation/views/my_notifications_view.dart
import 'package:check_job/presentation/controllers/notification/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/enities.dart';

class MyNotificationsView extends StatelessWidget {
  MyNotificationsView({super.key});

  final NotificationController controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBackPressed(context);
        }
      },
      child: Scaffold(
        backgroundColor: _blendWithWhite(context, 0.03),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildNotificationsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    // Marcar todas como leídas al salir
    controller.onPageExited();
    Get.back();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        GestureDetector(
          onTap: () => _onBackPressed(context),
          child: Container(
            padding: const EdgeInsets.all(11.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final notifications = controller.notifications;

      if (notifications.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('No hay notificaciones'),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _notificationCard(context, notifications[index]);
          },
        ),
      );
    });
  }

  Widget _notificationCard(BuildContext context, NotificationEntity notification) {
    Color typeColor = _getNotificationColor(notification.type, notification.body.toLowerCase());
    IconData icon = _getNotificationIcon(notification.type);

    return GestureDetector(
      onTap: () {
        if (!notification.read) {
          controller.markAsRead(notification.notificationID);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 105),
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(!notification.read ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: !notification.read
              ? Border.all(color: typeColor.withOpacity(0.3), width: 2)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: typeColor.withOpacity(0.1),
              child: Icon(icon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !notification.read ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: !notification.read ? Colors.grey.shade700 : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type, String body) {
    switch (type) {
      case 'task_rated':
        return body.contains("aprobada") ?  Colors.green : Colors.red;
      case 'invoice_overdue':
        return Colors.redAccent;
      case 'material_low':
        return Colors.orange;
      case 'material_critical':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task_rated':
      return Icons.star;
      case 'invoice_overdue':
        return Icons.warning;
      case 'material_low':
        return Icons.inventory_2;
      case 'material_critical':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}