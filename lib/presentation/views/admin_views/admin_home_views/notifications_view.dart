import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyNotificationsView extends StatelessWidget {
  const MyNotificationsView({super.key});

  final List<Map<String, dynamic>> notifications = const [
    {'title': 'Tarea Completada', 'message': 'TRAB-001 ha sido completada', 'time': 'Hace 2 minutos', 'read': false, 'type': 'success'},
    {'title': 'Nuevo Mensaje', 'message': 'Tienes un nuevo mensaje del cliente', 'time': 'Hace 15 minutos', 'read': false, 'type': 'info'},
    {'title': 'Stock Bajo', 'message': 'Aceite Motor está por debajo del mínimo', 'time': 'Hace 1 hora', 'read': true, 'type': 'warning'},
    {'title': 'Pago Recibido', 'message': 'Se ha recibido el pago de FAC-001', 'time': 'Hace 3 horas', 'read': true, 'type': 'success'},
    {'title': 'Recordatorio', 'message': 'Reunión con cliente a las 15:00', 'time': 'Hace 5 horas', 'read': true, 'type': 'info'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
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
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(11.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color:Theme.of(context).colorScheme.primary),
          ),
        ),
        // const SizedBox(width: 41),
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _notificationCard(context, notifications[index]);
        },
      ),
    );
  }

  Widget _notificationCard(BuildContext context, Map<String, dynamic> notification) {
    Color typeColor = Colors.blue;
    if (notification['type'] == 'success') typeColor = Colors.green;
    if (notification['type'] == 'warning') typeColor = Colors.orange;
    if (notification['type'] == 'error') typeColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        border: !notification['read'] ? Border.all(color: typeColor.withOpacity(0.3), width: 2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.1),
            child: Icon(_getNotificationIcon(notification['type']), size: 20, color: typeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !notification['read'] ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 12,
                    color: !notification['read'] ? Colors.grey.shade700 : Colors.grey.shade500,
                  ),
                ),
                Text(
                  notification['time'],
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          if (!notification['read'])
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
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}