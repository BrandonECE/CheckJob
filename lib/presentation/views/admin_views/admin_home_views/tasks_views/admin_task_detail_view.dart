// lib/presentation/views/admin/my_admin_task_detail_view.dart
import 'dart:typed_data';
import 'package:check_job/presentation/controllers/task/admin_task_controller.dart';
import 'package:check_job/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/entities/enities.dart';
import 'package:pdf/pdf.dart';

// PDF & Printing
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MyAdminTaskDetailView extends StatefulWidget {
  const MyAdminTaskDetailView({super.key});

  @override
  State<MyAdminTaskDetailView> createState() => _MyAdminTaskDetailViewState();
}

class _MyAdminTaskDetailViewState extends State<MyAdminTaskDetailView> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final AdminTaskController controller = Get.find<AdminTaskController>();
    final TaskEntity? t = controller.selectedTask.value;

    if (t == null) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          controller.updateIsLoading(false);
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No hay tarea seleccionada'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.updateIsLoading(false);
                    Get.back();
                  },
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Inicializar el estado seleccionado si es la primera vez
    _selectedStatus ??= t.status;

    final isCompleted = t.status.toLowerCase().contains('completed');
    final isApproved = t.clientFeedback?.approved;
    final isCompany =
        t.clientName.contains('Compañía') ||
        t.clientName.contains('S.A.') ||
        t.clientName.contains('C.A.');

    return PopScope(
          onPopInvokedWithResult: (didPop, result) {
          controller.updateIsLoading(false);
        },
      child: Scaffold(
        backgroundColor: _blendWithWhite(context, 0.03),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          _buildHeader(context, controller),
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
                          _buildStatusSelector(context, t),
                          const SizedBox(height: 18),
                          _buildUserActionButtons(
                            context,
                            isCompleted: isCompleted,
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
                          _buildCommentBox(context, t.comment?.text),
                          const SizedBox(height: 16),
                          _buildMetadataSection(context, t, isCompany),
                          const SizedBox(height: 24),
                          _buildPrintButton(context, t, controller),
                          if (t.clientFeedback == null) ...[
                            const SizedBox(height: 12),
                            _buildSaveButton(context, t),
                            const SizedBox(height: 12),
                            _buildDeleteButton(context, t),
                          ],
                          const SizedBox(height: 20),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'Vista de administrador • Gestión completa',
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminTaskController controller) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            controller.updateIsLoading(false);
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

  Widget _buildStatusSelector(BuildContext context, TaskEntity task) {
    final statuses = ['pending', 'in_progress', 'completed'];
    final statusLabels = {
      'pending': 'Pendiente',
      'in_progress': 'En Proceso',
      'completed': 'Completado',
    };

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
        Container(
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
          child: AbsorbPointer(
            absorbing: task.clientFeedback != null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
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
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      _selectedStatus = newStatus;
                    });
                  }
                },
              ),
            ),
          ),
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

    final bool isApprovedFinal = isApproved ?? false;
    final bool isRejected = isApproved == false;

    return Column(
      children: [
        // Estado del feedback si ya existe
        if (isApproved != null) ...[
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
                        ? 'Tarea aprobada por el cliente'
                        : 'Tarea rechazada por el cliente',
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

        // Botones de acción (solo visuales, no interactivos)
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

            // Botón Aprobar
            Expanded(
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
                        : accent1.withOpacity(0.3),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 18,
                        color: isApprovedFinal
                            ? Colors.white
                            : accent1.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aprobar',
                        style: TextStyle(
                          color: isApprovedFinal
                              ? Colors.white
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

  Widget _buildPrintButton(
    BuildContext context,
    TaskEntity task,
    AdminTaskController controller,
  ) {
    return Obx(() {
      final isLoading = controller.isPrintButtonLoading.value;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            controller.updateIsPrintButtonLoading(true);
            try {
              final pdfData = await _buildTaskPdfData(task);
              // abrir diálogo de impresión usando el PDF en memoria (no guardamos en disco)
              await Printing.layoutPdf(onLayout: (format) async => pdfData);
            } catch (e) {
              print("ERROR $e");
              _showErrorSnackbar('Error al generar PDF: $e');
            }
            controller.updateIsPrintButtonLoading(false);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(Icons.print, color: Theme.of(context).colorScheme.primary),
          label: isLoading
              ? Text(
                  'Imprimiendo...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              : Text(
                  'Imprimir Detalles',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }

  /// Genera un PDF en memoria con la información de la tarea y lo devuelve como Uint8List.
  Future<Uint8List> _buildTaskPdfData(TaskEntity task) async {
    final doc = pw.Document();

    // imagen opcional (empleado)
    pw.MemoryImage? employeeImage;
    if (task.photoEmployeeData != null) {
      try {
        employeeImage = pw.MemoryImage(task.photoEmployeeData!);
      } catch (_) {
        employeeImage = null;
      }
    }

    final createdAt = task.createdAt.toDate();
    final completedAt = task.completedAt?.toDate();

    // tabla de materiales
    final materialRows = <List<String>>[];
    for (final m in task.materialsUsed) {
      materialRows.add([m.materialName, m.quantity.toString(), m.unit]);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(28),
        build: (context) {
          return <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Detalles del Trabajo',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'ID: ${task.taskID}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (employeeImage != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 0.5,
                        color: PdfColors.grey300,
                      ),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(employeeImage, fit: pw.BoxFit.cover),
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(height: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // General info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        task.title,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Cliente: ${task.clientName}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Asignado a: ${task.assignedEmployeeName}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Estado: ${_formatStatus(task.status)}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Creada: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      if (completedAt != null)
                        pw.Text(
                          'Completada: ${completedAt.day}/${completedAt.month}/${completedAt.year}',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 14),

            // Descripción
            pw.Text(
              'Descripción',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              task.description,
              style: pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 12),

            // Materiales
            pw.Text(
              'Materiales usados',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (materialRows.isEmpty)
              pw.Text(
                'No se han registrado materiales',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey),
              )
            else
              pw.Table.fromTextArray(
                context: context,
                headers: ['Material', 'Cantidad', 'Unidad'],
                data: materialRows,
                headerStyle: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(fontSize: 11),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
                columnWidths: {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                },
              ),

            pw.SizedBox(height: 12),

            // Comentario principal (si existe)
            pw.Text(
              'Comentario',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              task.comment?.text ?? 'No hay comentarios',
              style: pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 14),

            // Pie con metadatos
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Generado desde la app • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  Widget _buildSaveButton(BuildContext context, TaskEntity task) {
    final AdminTaskController controller = Get.find<AdminTaskController>();

    return Obx(() {
      final bool isLoading = controller.isButtonLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () async {
                  if (_selectedStatus != task.status) {
                    final bool? confirm = await Get.dialog<bool>(
                      Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 28,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              30,
                              20,
                              30,
                              30,
                            ), // contentPadding similar a defaultDialog
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // título con padding superior parecido a titlePadding
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    'Confirmar Cambios',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),

                                // mensaje
                                Text(
                                  '¿Estás seguro de que deseas cambiar el estado de "${_formatStatus(task.status)}" a "${_formatStatus(_selectedStatus!)}"?',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 18),

                                // botones (proporción más contenida)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.12),
                                          ),
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Get.back(result: true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _statusColor(
                                            _selectedStatus!,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: const Text(
                                          'Confirmar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    if (confirm == true) {
                      await controller.updateTaskStatus(
                        task.taskID,
                        _selectedStatus!,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Información',
                      'No hay cambios para guardar',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save, color: Colors.white, size: 20),
          label: isLoading
              ? const Text(
                  'Guardando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              : const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildDeleteButton(BuildContext context, TaskEntity task) {
    final AdminTaskController controller = Get.find<AdminTaskController>();

    return Obx(() {
      final bool isLoading = controller.isButtonLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  Get.dialog(
                    Dialog(
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 28,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Confirmar eliminación',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Text(
                                '¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.12),
                                        ),
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteTask(task.taskID);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: true,
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.delete, color: Colors.white, size: 20),
          label: isLoading
              ? const Text(
                  'Eliminando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              : const Text(
                  'Eliminar Tarea',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
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

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
