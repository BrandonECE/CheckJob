import 'package:check_job/domain/entities/task_entity/task_material_used_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/entities/enities.dart';
import '../../../../utils/utils.dart';

class MyUserTaskDetailView extends StatelessWidget {
  const MyUserTaskDetailView({super.key});


  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 26,
    vertical: 28,
  );

  @override
  Widget build(BuildContext context) {
    final t = TaskEntity.example;
    final isCompleted = t.status.toLowerCase().contains('completed');
    final isApproved = t.clientFeedback?.approved;
    final isCompany =
        t.clientName.contains('Compañía') ||
        t.clientName.contains('S.A.') ||
        t.clientName.contains('C.A.');

    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildHeader(context),
                        const SizedBox(height: 16),

                        // Nueva tarjeta principal rediseñada
                        _buildNewMainCard(context, t, isCompany),

                        const SizedBox(height: 18),

                        // título + id como en la lista (coherente)
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID: ${t.taskID}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // chip estado alineado a la derecha
                        Row(
                          children: [
                            const Spacer(),
                            _statusChipWithIcon(context, t.status),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // botones acción (con advertencia solo si está completado)
                        _buildActionButtons(
                          context,
                          isCompleted: isCompleted,
                          isApproved: isApproved,
                        ),

                        const SizedBox(height: 18),

                        // Descripción
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            t.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Materiales
                        Text(
                          'Materiales usados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _materialsList(context, t.materialsUsed),

                        const SizedBox(height: 16),

                        // Comentario
                        Text(
                          'Comentario',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCommentBox(
                          context,
                          t.comment?.text,
                          isApproved != null,
                        ),

                        const SizedBox(height: 16),

                        // Metadatos
                        _buildMetadataSection(context, t, isCompany),

                        const Spacer(),

                        const SizedBox(height: 12),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Detalle de tarea • Interfaz consistente',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botón de retroceso
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
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
          ),
        ),

        // Título
        Text(
          'Detalles del Trabajo',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

          const SizedBox(width: 41),
      ],
    );
  }

  Widget _buildNewMainCard(BuildContext context, TaskEntity t, bool isCompany) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(t.status);
    final avatarInnerSize = 66.0;
    final ringPadding = 6.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Cliente y Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isCompany ? Icons.business : Icons.person,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(t.status),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatStatus(t.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Fila media: Información de la tarea
          Row(
            children: [
              // Información de fecha y asignado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha',
                      _formatDate(t.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person,
                      'Asignado a',
                      t.assignedEmployeeName,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Avatar con anillo (diseño que te gustaba) - ahora con foto
              _buildAvatarRing(context, avatarInnerSize, ringPadding, t),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarRing(
    BuildContext context,
    double avatarInnerSize,
    double ringPadding,
    TaskEntity task,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradStart = colorScheme.primary.withOpacity(0.45);
    final gradEnd = colorScheme.primary.withOpacity(0.06);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(ringPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradStart, gradEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: avatarInnerSize,
            height: avatarInnerSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: task.photoData != null
                  ? ClipOval(
                      child: Image.memory(
                        task.photoData!,
                        width: avatarInnerSize - 4,
                        height: avatarInnerSize - 4,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 32,
                            color: colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(Icons.person, size: 32, color: colorScheme.primary),
            ),
          ),
        ),
        // estado pequeño (dot)
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
  BuildContext context, {
  required bool isCompleted,
  required bool? isApproved,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final errorColor = colorScheme.error;
  final accent1 = colorScheme.primary;
  final accent2 = colorScheme.primary.withOpacity(0.95);

  // Determinar el estado de los botones
  final bool canInteract = isCompleted && isApproved == null;
  final bool isApprovedFinal = isApproved ?? false;
  final bool isRejected = isApproved == false;

  return Column(
    children: [
      // Advertencia sobre comentarios - solo aparece si está completado y no aprobado/rechazado
      if (isCompleted && isApproved == null) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accent1.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent1.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: accent1),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Puedes agregar un comentario antes de aprobar o rechazar',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],

      // Botones de acción
      Row(
        children: [
          // Botón Rechazar
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isRejected
                    ? errorColor.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRejected
                      ? errorColor
                      : errorColor.withOpacity(0.14),
                  width: isRejected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      size: 18,
                      color: isRejected
                          ? errorColor
                          : errorColor.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rechazar',
                      style: TextStyle(
                        color: isRejected
                            ? errorColor
                            : errorColor.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Botón Aprobar - MEJORADO para mayor visibilidad cuando está en true
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isApprovedFinal
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent1,
                          accent1.withOpacity(0.8), // Gradiente más intenso
                        ],
                      )
                    : null,
                color: !isApprovedFinal ? Colors.white : null,
                border: Border.all(
                  color: isApprovedFinal
                      ? accent1.withOpacity(0.5) // Borde más visible
                      : accent1.withOpacity(0.3),
                  width: isApprovedFinal ? 1.5 : 1, // Borde más grueso
                ),
                boxShadow: isApprovedFinal
                    ? [
                        BoxShadow(
                          color: accent1.withOpacity(0.3), // Sombra coloreada
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      size: 18,
                      color: isApprovedFinal
                          ? Colors.white
                          : accent1.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Aprobar',
                      style: TextStyle(
                        color: isApprovedFinal
                            ? Colors.white
                            : accent1.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        shadows: isApprovedFinal
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildCommentBox(
    BuildContext context,
    String? initialText,
    bool isReadOnly,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: initialText),
        style: TextStyle(
          fontSize: 15,
          color: isReadOnly ? Colors.grey : Colors.black,
        ),
        maxLines: null,
        minLines: 4,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          hintText: isReadOnly
              ? 'Comentario registrado'
              : 'Describe observaciones o notas...',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          isCollapsed: true,
        ),
      ),
    );
  }

  Widget _materialsList(
    BuildContext context,
    List<TaskMaterialUsedEntity> materials,
  ) {
    if (materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'No se han registrado materiales',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      children: materials.map((material) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  material.materialName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${material.quantity} ${material.unit}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataSection(
    BuildContext context,
    TaskEntity t,
    bool isCompany,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              _formatDate(t.createdAt),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'Asignado: ${t.assignedEmployeeName}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              isCompany ? Icons.business : Icons.person,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Cliente: ${t.clientName}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChipWithIcon(BuildContext context, String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    if (status.toLowerCase().contains('completed')) return Icons.check_circle;
    if (status.toLowerCase().contains('in_progress')) return Icons.autorenew;
    if (status.toLowerCase().contains('pending')) return Icons.access_time;
    return Icons.assignment;
  }

  String _formatStatus(String status) {
    if (status == 'completed') return 'Completado';
    if (status == 'in_progress') return 'En Proceso';
    if (status == 'pending') return 'Pendiente';
    return status;
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day} ${getMonthName(date.month)} ${date.year}';
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('completed')) return Colors.green;
    if (status.toLowerCase().contains('in_progress')) return Colors.orange;
    if (status.toLowerCase().contains('pending')) return Colors.grey;
    return Colors.blue;
  }

  // Helper: mezcla un tint del primary sobre blanco (igual patrón)
  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
