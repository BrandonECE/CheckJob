import 'package:check_job/domain/entities/task_entity/task_material_used_entity.dart';
import 'package:check_job/presentation/controllers/task/user_task_controller.dart';
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
    return Obx(() {
      final controller = Get.find<UserTaskController>();
      final t = controller.selectedTask.value;

      if (t == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No hay tarea seleccionada'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        );
      }

      final isCompleted = t.status.toLowerCase().contains('completed');
      final hasFeedback = t.clientFeedback != null;
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
                          _buildNewMainCard(context, t, isCompany),
                          const SizedBox(height: 18),
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
                          Row(
                            children: [
                              const Spacer(),
                              _statusChipWithIcon(context, t.status),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildActionButtons(
                            context,
                            controller: controller,
                            task: t,
                            isCompleted: isCompleted,
                            hasFeedback: hasFeedback,
                            isApproved: isApproved,
                          ),
                          const SizedBox(height: 18),
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

                          // SECCIÓN DE COMENTARIOS - Mejorada
                          _buildCommentSection(
                            context,
                            controller,
                            t,
                            isCompleted,
                            hasFeedback,
                          ),

                          const SizedBox(height: 16),
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
    });
  }

 Widget _buildCommentSection(
  BuildContext context,
  UserTaskController controller,
  TaskEntity task,
  bool isCompleted,
  bool hasFeedback,
) {
  // Solo mostrar comentarios existentes, no campo editable
  if (task.comment != null && task.comment!.text.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Comentario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildReadOnlyCommentBox(context, task.comment!.text),
      ],
    );
  }

  // Si no hay comentarios, no mostrar nada
  return const SizedBox.shrink();
}

  // Widget _buildEditableCommentBox(
  //   BuildContext context,
  //   UserTaskController controller,
  // ) {
  //   return Container(
  //     constraints: const BoxConstraints(minHeight: 110),
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       onChanged: controller.updateTempComment,
  //       style: const TextStyle(fontSize: 15, color: Colors.black),
  //       maxLines: null,
  //       minLines: 4,
  //       decoration: const InputDecoration(
  //         hintText: 'Describe observaciones o notas...',
  //         border: InputBorder.none,
  //         hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
  //         isCollapsed: true,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildReadOnlyCommentBox(BuildContext context, String comment) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
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
      child: TextFormField(
        initialValue: comment,
        readOnly: true, // evita que el usuario edite
        enableInteractiveSelection:
            true, // permite seleccionar / copiar si quieres
        minLines: 4,
        maxLines: null,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Sin comentarios',
          hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // ... resto de métodos IGUALES a los que ya tienes ...
  Widget _buildHeader(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
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
          Row(
            children: [
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
              _buildAvatarRing(context, avatarInnerSize, ringPadding, t),
            ],
          ),
        ],
      ),
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
              child: task.photoEmployeeData != null
                  ? ClipOval(
                      child: Image.memory(
                        task.photoEmployeeData!,
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

  Widget _buildActionButtons(
    BuildContext context, {
    required UserTaskController controller,
    required TaskEntity task,
    required bool isCompleted,
    required bool hasFeedback,
    required bool? isApproved,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;
    final accent1 = colorScheme.primary;

    final bool canInteract = isCompleted && !hasFeedback;
    final bool isApprovedFinal = isApproved ?? false;
    final bool isRejected = isApproved == false;

    return Column(
      children: [
        // Advertencia sobre comentarios - solo aparece si está completado y no aprobado/rechazado
        if (isCompleted && !hasFeedback) ...[
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

        // Estado del feedback si ya existe
        if (hasFeedback) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isApprovedFinal
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isApprovedFinal
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isApprovedFinal ? Icons.check_circle : Icons.cancel,
                  color: isApprovedFinal ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isApprovedFinal
                        ? 'Tarea aprobada - Gracias por tu feedback'
                        : 'Tarea rechazada - Lamentamos los inconvenientes',
                    style: TextStyle(
                      color: isApprovedFinal
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
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
              child: Obx(() {
                return GestureDetector(
                  onTap: canInteract && !controller.isSubmittingFeedback.value
                      ? () => _showFeedbackDialog(
                          context,
                          controller,
                          task,
                          approved: false,
                        )
                      : null,
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
                            : errorColor.withOpacity(canInteract ? 0.14 : 0.06),
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
                      child: controller.isSubmittingFeedback.value
                          ? const CircularProgressIndicator()
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 18,
                                  color: isRejected
                                      ? errorColor
                                      : errorColor.withOpacity(
                                          canInteract ? 0.5 : 0.3,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rechazar',
                                  style: TextStyle(
                                    color: isRejected
                                        ? errorColor
                                        : errorColor.withOpacity(
                                            canInteract ? 0.5 : 0.3,
                                          ),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),

            // Botón Aprobar
            Expanded(
              child: Obx(() {
                return GestureDetector(
                  onTap: canInteract && !controller.isSubmittingFeedback.value
                      ? () => _showFeedbackDialog(
                          context,
                          controller,
                          task,
                          approved: true,
                        )
                      : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isApprovedFinal
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [accent1, accent1.withOpacity(0.8)],
                            )
                          : null,
                      color: !isApprovedFinal ? Colors.white : null,
                      border: Border.all(
                        color: isApprovedFinal
                            ? accent1.withOpacity(0.5)
                            : accent1.withOpacity(canInteract ? 0.3 : 0.1),
                        width: isApprovedFinal ? 1.5 : 1,
                      ),
                      boxShadow: isApprovedFinal
                          ? [
                              BoxShadow(
                                color: accent1.withOpacity(0.3),
                                blurRadius: 10,
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
                      child: controller.isSubmittingFeedback.value
                          ? const CircularProgressIndicator(
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: isApprovedFinal
                                      ? Colors.white
                                      : accent1.withOpacity(
                                          canInteract ? 0.5 : 0.3,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Aprobar',
                                  style: TextStyle(
                                    color: isApprovedFinal
                                        ? Colors.white
                                        : accent1.withOpacity(
                                            canInteract ? 0.5 : 0.3,
                                          ),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  void _showFeedbackDialog(
  BuildContext context,
  UserTaskController controller,
  TaskEntity task, {
  required bool approved,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  Get.defaultDialog(
    backgroundColor: Colors.white,
    titlePadding: const EdgeInsets.only(top: 30),
    contentPadding: const EdgeInsets.only(
      top: 20,
      right: 30,
      bottom: 30,
      left: 30,
    ),
    title: approved ? 'Aprobar Tarea' : 'Rechazar Tarea',

    // Contenido: texto + campo para comentario opcional
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          approved
              ? '¿Estás seguro de que deseas aprobar esta tarea?'
              : '¿Estás seguro de que deseas rechazar esta tarea?',
          style: const TextStyle(
            fontSize: 14.5,
            color: Colors.black87,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        
        // Campo de comentario agregado aquí
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            onChanged: controller.updateTempComment,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Comentario opcional...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              isCollapsed: true,
            ),
          ),
        ),

         const SizedBox(height: 8),
        
      ],
    ),

    // Botón confirmar (Elevated)
    confirm: TextButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: approved ? colorScheme.primary : Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
      onPressed: () async {
        try {
          controller.submitTaskFeedback(
            taskId: task.taskID,
            approved: approved,
            comment: controller.tempComment.value.isNotEmpty
                ? controller.tempComment.value
                : null,
          );
        } catch (e) {
          // opcional: manejar error
        } finally {
          Get.back();
          FocusScope.of(context).unfocus();
        }
      },
      child: Text(approved ? 'Aprobar' : 'Rechazar'),
    ),

    // Botón cancelar
    cancel: TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundColor: colorScheme.primary,
      ),
      onPressed: () {
        controller.updateTempComment(''); // Limpiar comentario al cancelar
        Get.back();
      },
      child: const Text('Cancelar'),
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

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
