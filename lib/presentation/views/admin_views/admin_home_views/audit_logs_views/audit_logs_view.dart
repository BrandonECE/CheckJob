// lib/presentation/views/my_audit_logs_view.dart
import 'package:check_job/domain/entities/audit_log_entity.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/utils/utils.dart';

class MyAuditLogsView extends StatelessWidget {
  MyAuditLogsView({super.key});

  final AuditLogController controller = Get.find<AuditLogController>();

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
              onChanged: (value) => controller.setSearchQuery(value),
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final logs = controller.filteredLogs;

      if (logs.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('No hay registros de auditoría'),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return _logCard(context, logs[index]);
          },
        ),
      );
    });
  }

  Widget _logCard(BuildContext context, AuditLogEntity log) {
    final actionColor = _getActionColor(log.action);
    final timestamp = log.timestamp;

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
                _getActionIcon(log.action),
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
                  _formatAction(log.action),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actor: ${log.actorID}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  log.target,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'ID: ${log.auditLogID}',
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
    case 'task_created':
      return Icons.assignment_add;
    case 'task_updated':
      return Icons.assignment;
    case 'task_deleted':
      return Icons.assignment_late_rounded;
    case 'employee_created':
      return Icons.person_add;
    case 'employee_deleted':
      return Icons.person_remove;
    case 'client_created':
      return Icons.business_center;
    case 'client_deleted':
      return Icons.business_center_rounded;
    case 'material_created':
      return Icons.inventory_2;
    case 'material_updated':
      return Icons.inventory;
    case 'material_deleted':
      return Icons.inventory_2_outlined;
    case 'invoice_managed':
      return Icons.receipt;
    case 'report_generated':
      return Icons.assessment;
    case 'report_deleted':
      return Icons.assessment_outlined; // Icono para reporte eliminado
    default:
      return Icons.help_outline;
  }
}

Color _getActionColor(String action) {
  switch (action) {
    case 'task_created':
      return Colors.green;
    case 'task_updated':
      return Colors.blue;
    case 'task_deleted':
      return Colors.red;
    case 'employee_created':
      return Colors.teal;
    case 'employee_deleted':
      return Colors.orange;
    case 'client_created':
      return Colors.purple;
    case 'client_deleted':
      return Colors.deepOrange;
    case 'material_created':
      return Colors.indigo;
    case 'material_updated':
      return Colors.cyan;
    case 'material_deleted':
      return Colors.brown;
    case 'invoice_managed':
      return Colors.amber;
    case 'report_generated':
      return Colors.lightGreen;
    case 'report_deleted':
      return Colors.red.shade700; // Color rojo más oscuro para eliminación
    default:
      return Colors.grey;
  }
}

String _formatAction(String action) {
  switch (action) {
    case 'task_created':
      return 'Tarea Creada';
    case 'task_updated':
      return 'Tarea Actualizada';
    case 'task_deleted':
      return 'Tarea Eliminada';
    case 'employee_created':
      return 'Empleado Creado';
    case 'employee_deleted':
      return 'Empleado Eliminado';
    case 'client_created':
      return 'Cliente Creado';
    case 'client_deleted':
      return 'Cliente Eliminado';
    case 'material_created':
      return 'Material Creado';
    case 'material_updated':
      return 'Material Actualizado';
    case 'material_deleted':
      return 'Material Eliminado';
    case 'invoice_managed':
      return 'Factura Gestionada';
    case 'report_generated':
      return 'Reporte Generado';
    case 'report_deleted':
      return 'Reporte Eliminado'; // Texto para reporte eliminado
    default:
      return 'Acción Desconocida';
  }
}

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}