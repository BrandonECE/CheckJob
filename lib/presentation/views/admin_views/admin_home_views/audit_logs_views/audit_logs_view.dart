import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../utils/utils.dart';

class MyAuditLogsView extends StatelessWidget {
 MyAuditLogsView({super.key});

  final List<Map<String, dynamic>> auditLogs =  [
    {
      'auditLogID': 'log_001',
      'action': 'database_initialized',
      'actorID': 'admin_001',
      'target': 'complete_database',
      'timestamp': DateTime(2025, 9, 20, 1, 50, 53),
    },
    {
      'auditLogID': 'log_002',
      'action': 'user_created',
      'actorID': 'admin_001',
      'target': 'user_123',
      'timestamp': DateTime(2025, 9, 19, 14, 30, 22),
    },
    {
      'auditLogID': 'log_003',
      'action': 'task_assigned',
      'actorID': 'manager_002',
      'target': 'task_456',
      'timestamp': DateTime(2025, 9, 18, 9, 15, 17),
    },
    {
      'auditLogID': 'log_004',
      'action': 'permissions_updated',
      'actorID': 'admin_001',
      'target': 'user_789',
      'timestamp': DateTime(2025, 9, 17, 16, 45, 38),
    },
    {
      'auditLogID': 'log_005',
      'action': 'backup_completed',
      'actorID': 'system',
      'target': 'database_backup',
      'timestamp': DateTime(2025, 9, 16, 23, 10, 5),
    },
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
              _buildSearchField(context),
              const SizedBox(height: 20),
              _buildLogsList(context),
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
        GestureDetector(
          onTap: () => Get.back(),
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
        Text(
          'Auditoría',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (_) {},
              decoration: InputDecoration(
                hintText: 'Buscar registros...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: auditLogs.length,
        itemBuilder: (context, index) {
          return _logCard(context, auditLogs[index]);
        },
      ),
    );
  }

  Widget _logCard(BuildContext context, Map<String, dynamic> log) {
    final color = Theme.of(context).colorScheme.primary;
    final timestamp = log['timestamp'] as DateTime;
    final actionColor = _getActionColor(log['action']);

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
      ),
      child: Row(
        children: [
          // Avatar con borde de gradiente
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  actionColor.withOpacity(0.5),
                  actionColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                _getActionIcon(log['action']),
                size: 24,
                color: actionColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAction(log['action']),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actor: ${log['actorID']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Objetivo: ${log['target']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'ID: ${log['auditLogID']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          // Fecha y hora
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatDateToYMD(timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatTimeToAmPm(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'database_initialized':
        return Icons.storage;
      case 'user_created':
        return Icons.person_add;
      case 'task_assigned':
        return Icons.assignment;
      case 'permissions_updated':
        return Icons.security;
      case 'backup_completed':
        return Icons.backup;
      default:
        return Icons.history;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'database_initialized':
        return Colors.green;
      case 'user_created':
        return Colors.blue;
      case 'task_assigned':
        return Colors.orange;
      case 'permissions_updated':
        return Colors.purple;
      case 'backup_completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatAction(String action) {
    switch (action) {
      case 'database_initialized':
        return 'BD Inicializada';
      case 'user_created':
        return 'Usuario Creado';
      case 'task_assigned':
        return 'Tarea Asignada';
      case 'permissions_updated':
        return 'Permisos Actualizados';
      case 'backup_completed':
        return 'Respaldo Completado';
      default:
        return action;
    }
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}