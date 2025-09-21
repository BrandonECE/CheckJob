import 'package:check_job/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../domain/entities/enities.dart';

class MyAdminTaskDetailView extends StatelessWidget {
  const MyAdminTaskDetailView({super.key});

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 26,
    vertical: 28,
  );

  @override
  Widget build(BuildContext context) {
    final t = TaskEntity.example;
    final isCompleted = t.status.toLowerCase().contains('completed');
    final isApproved = t.clientFeedback?.approved;
    final isCompany = t.clientName.contains('Compañía') ||
        t.clientName.contains('S.A.') ||
        t.clientName.contains('C.A.');

    final initialStatus = () {
      final s = t.status.toLowerCase();
      if (s == 'completed' || s == 'in_progress' || s == 'pending') {
        return s;
      }
      return 'pending';
    }();

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

                        // Selector de estado para admin (ahora editable sin StatefulWidget)
                        _buildStatusSelector(context, initialStatus),

                        const SizedBox(height: 18),

                        // Botones de acción del usuario (solo visualización para admin)
                        _buildUserActionButtons(
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

                        // Comentario (solo lectura para admin)
                        Text(
                          'Comentario',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCommentBox(context, t.comment?.text),

                        const SizedBox(height: 16),

                        // Metadatos
                        _buildMetadataSection(context, t, isCompany),

                        // Espaciado adicional antes del botón de guardar
                        const SizedBox(height: 24),

                        // Botón de guardar para admin
                        // Botón de imprimir (nuevo)
                        _buildPrintButton(context),

                        const SizedBox(height: 12),

                        _buildSaveButton(context),

                        const SizedBox(height: 12),

                        // Botón de eliminar
                        _buildDeleteButton(context),

                        const SizedBox(height: 20),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Vista de administrador • Solo lectura',
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

        // Espacio para mantener la simetría
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

  // Ahora el selector usa ValueNotifier + ValueListenableBuilder para que sea desplegable
  // sin convertir el widget en StatefulWidget.
  Widget _buildStatusSelector(BuildContext context, String initialStatus) {
    final statuses = ['pending', 'in_progress', 'completed'];
    final statusLabels = {
      'pending': 'Pendiente',
      'in_progress': 'En Proceso',
      'completed': 'Completado',
    };

    // Nota: se crea dentro del build. Si tu UI se reconstruye mucho y quieres persistir
    // la selección entre reconstrucciones, considera manejar este ValueNotifier desde
    // un controlador GetX o pasarlo desde arriba. Para muchos casos esto funciona bien.
    final statusNotifier = ValueNotifier<String>(initialStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de la tarea',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: statusNotifier,
          builder: (context, value, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: statuses.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 16,
                            color: _statusColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusLabels[status] ?? status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) statusNotifier.value = v;
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserActionButtons(
    BuildContext context, {
    required bool isCompleted,
    required bool? isApproved,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;
    final accent1 = colorScheme.primary;

    // Determinar el estado de los botones
    final bool isApprovedFinal = isApproved ?? false;
    final bool isRejected = isApproved == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Decisión del usuario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Botón Rechazar (solo visual)
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isRejected
                      ? errorColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRejected
                        ? errorColor
                        : errorColor.withOpacity(0.14),
                    width: isRejected ? 2 : 1,
                  ),
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
                            : errorColor.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rechazar',
                        style: TextStyle(
                          color: isRejected
                              ? errorColor
                              : errorColor.withOpacity(0.3),
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

            // Botón Aprobar (solo visual)
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isApprovedFinal
                      ? accent1.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isApprovedFinal ? accent1 : accent1.withOpacity(0.3),
                    width: isApprovedFinal ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 18,
                        color: isApprovedFinal
                            ? accent1
                            : accent1.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aprobar',
                        style: TextStyle(
                          color: isApprovedFinal
                              ? accent1
                              : accent1.withOpacity(0.3),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isApproved == null)
          Text(
            'El usuario aún no ha tomado una decisión',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildCommentBox(BuildContext context, String? initialText) {
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
        style: TextStyle(fontSize: 15, color: Colors.grey),
        maxLines: null,
        minLines: 4,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'No hay comentarios',
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

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Aquí iría la lógica para guardar los cambios
          Get.snackbar(
            'Guardado',
            'Los cambios se han guardado correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, color: Colors.white, size: 20),
        label: const Text(
          'Guardar Cambios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Nuevo: botón de impresión
  Widget _buildPrintButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Aquí puedes integrar un paquete de impresión (ej. `printing`) para generar PDF
          // y enviarlo a impresora. Por ahora mostramos una notificación de ejemplo.
          Get.snackbar(
            'Impresión',
            'Preparando documento para imprimir...',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Ejemplo (comentado) de uso del paquete `printing`:
          // import 'package:printing/printing.dart';
          // Printing.layoutPdf(onLayout: (format) async => myPdfDocument);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(Icons.print, color: Theme.of(context).colorScheme.primary),
        label: Text(
          'Imprimir Detalles',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Aquí iría la lógica para eliminar la tarea
          Get.defaultDialog(
            title: 'Confirmar eliminación',
            middleText: '¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.',
            textConfirm: 'Eliminar',
            textCancel: 'Cancelar',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              Get.snackbar(
                'Eliminado',
                'La tarea ha sido eliminada correctamente',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
        label: const Text(
          'Eliminar Tarea',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Icons.check_circle;
    if (lowerStatus.contains('in_progress')) return Icons.autorenew;
    if (lowerStatus.contains('pending')) return Icons.access_time;
    return Icons.assignment;
  }

  String _formatStatus(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed') return 'Completado';
    if (lowerStatus == 'in_progress') return 'En Proceso';
    if (lowerStatus == 'pending') return 'Pendiente';
    return status;
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day} ${getMonthName(date.month)} ${date.year}';
  }

  Color _statusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Colors.green;
    if (lowerStatus.contains('in_progress')) return Colors.orange;
    if (lowerStatus.contains('pending')) return Colors.grey;
    return Colors.blue;
  }

  // Helper: mezcla un tint del primary sobre blanco (igual patrón)
  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
