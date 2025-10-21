// lib/presentation/views/reports/my_reports_view.dart
import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:get/get.dart';
import 'package:check_job/domain/entities/report_entity.dart';
import 'package:check_job/presentation/controllers/report/report_controller.dart';

class MyReportsView extends StatefulWidget {
  const MyReportsView({super.key});

  @override
  State<MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<MyReportsView> {
  final ReportController controller = Get.find<ReportController>();

  DateRangeOption _selectedOption = DateRangeOption.currentMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customStart = DateTime(now.year, now.month, 1);
    _customEnd = now;
  }

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
              _buildReportTypes(context),
              const SizedBox(height: 20),
              _buildReportsList(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
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
          'Gen. Reportes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => controller.loadSavedReports(),
        ),
      ],
    );
  }

  // ---------- Report types ----------
  Widget _buildReportTypes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Reporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ReportType.values
              .map((t) => _reportTypeButton(context, t))
              .toList(),
        ),
      ],
    );
  }

  Widget _reportTypeButton(BuildContext context, ReportType type) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDateRangeDialog(type),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                type.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Reports list ----------
  Widget _buildReportsList(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes Generados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoading.value) {
              // Mostrar spinner mientras cargan los reportes desde DB
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.reports.isEmpty && controller.savedReports.isEmpty) {
              return Expanded(child: _buildEmptyState(context));
            }

            return Expanded(
              child: ListView(
                children: [
                  if (controller.reports.isNotEmpty) ...[
                    _buildSectionTitle('Nuevos Reportes'),
                    ...controller.reports
                        .map((r) => _reportCard(context, r))
                        .toList(),
                  ],
                  if (controller.savedReports.isNotEmpty) ...[
                    _buildSectionTitle('Reportes Guardados'),
                    ...controller.savedReports
                        .map((r) => _reportCard(context, r))
                        .toList(),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes generados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona un tipo de reporte para comenzar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------- Report card ----------
  Widget _reportCard(BuildContext context, ReportEntity report) {
    final color = report.format?.color ?? Theme.of(context).colorScheme.primary;
    final icon = report.format?.icon ?? Icons.picture_as_pdf;
    final formatLabel = report.format?.label ?? '';

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
          _iconBox(icon, color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.titleForUI,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                 'Período: ${report.dateRange.replaceAll('_', '\n')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Tamaño: ${report.formattedSize} • $formatLabel',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildPopupMenu(report),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  PopupMenuButton<String> _buildPopupMenu(ReportEntity report) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      onSelected: (v) => _handleReportAction(v, report),
      itemBuilder: (ctx) => [
        _popupMenuItem(ctx, 'download', Icons.download, 'Descargar'),
        _popupMenuItem(ctx, 'share', Icons.share, 'Compartir'),
        _popupMenuItem(ctx, 'delete', Icons.delete, 'Eliminar'),
      ],
    );
  }

  PopupMenuItem<String> _popupMenuItem(
    BuildContext ctx,
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  // ---------- Date range dialog ----------
  void _showDateRangeDialog(ReportType type) {
    DateRangeOption selectedOption = _selectedOption;
    DateTime tempStart = _customStart ?? DateTime.now();
    DateTime tempEnd = _customEnd ?? DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        final colorScheme = Theme.of(dialogCtx).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (ctx2, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          'Reporte de ${type.label}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      type.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selecciona el período:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...DateRangeOption.values.map((option) {
                      String subtitle = controller.getDateRangeDisplay(option);
                      if (option == DateRangeOption.custom)
                        subtitle =
                            '${_formatDate(tempStart)} - ${_formatDate(tempEnd)}';
                      return RadioListTile<DateRangeOption>(
                        title: Text(
                          option.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (v) {
                          setStateDialog(() {
                            selectedOption = v!;
                            if (selectedOption == DateRangeOption.custom) {
                              final now = DateTime.now();
                              tempStart =
                                  _customStart ??
                                  DateTime(now.year, now.month, 1);
                              tempEnd = _customEnd ?? now;
                            }
                          });
                        },
                      );
                    }).toList(),
                    if (selectedOption == DateRangeOption.custom) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.12),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: colorScheme.primary,
                              ),
                              onPressed: () async {
                                final chosen = await _showDatePickerDialog(
                                  dialogCtx,
                                  'Seleccionar fecha inicio',
                                  tempStart,
                                );
                                if (chosen != null) {
                                  setStateDialog(
                                    () => tempStart = DateTime(
                                      chosen.year,
                                      chosen.month,
                                      chosen.day,
                                    ),
                                  );
                                }
                              },
                              child: Text('Inic: ${_formatDate(tempStart)}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.12),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: colorScheme.primary,
                              ),
                              onPressed: () async {
                                final chosen = await _showDatePickerDialog(
                                  dialogCtx,
                                  'Seleccionar fecha fin',
                                  tempEnd,
                                );
                                if (chosen != null) {
                                  setStateDialog(
                                    () => tempEnd = DateTime(
                                      chosen.year,
                                      chosen.month,
                                      chosen.day,
                                    ),
                                  );
                                }
                              },
                              child: Text('Fin: ${_formatDate(tempEnd)}'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: colorScheme.primary,
                            ),
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 6,
                            ),
                            onPressed: () {
                              DateTimeRangeEntity range;
                              if (selectedOption == DateRangeOption.custom) {
                                if (tempStart.isAfter(tempEnd)) {
                                  Get.snackbar(
                                    'Error',
                                    'La fecha de inicio no puede ser posterior a la de fin',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.shade600,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                range = DateTimeRangeEntity(
                                  start: DateTime(
                                    tempStart.year,
                                    tempStart.month,
                                    tempStart.day,
                                  ),
                                  end: DateTime(
                                    tempEnd.year,
                                    tempEnd.month,
                                    tempEnd.day,
                                    23,
                                    59,
                                    59,
                                  ),
                                );
                                _customStart = tempStart;
                                _customEnd = tempEnd;
                              } else {
                                range = controller.getDateRangeForOption(
                                  selectedOption,
                                );
                                _selectedOption = selectedOption;
                              }
                              Navigator.of(dialogCtx).pop();
                              _showConfirmationDialog(type, range);
                            },
                            child: const Text(
                              'Continuar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------- Date picker dialog ----------
  Future<DateTime?> _showDatePickerDialog(
    BuildContext context,
    String title,
    DateTime initialDate,
  ) {
    return showDialog<DateTime>(
      context: context,
      builder: (dCtx) {
        DateTime temp = initialDate;
        final colorSchemeLocal = Theme.of(dCtx).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorSchemeLocal.primary,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => Navigator.of(dCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 330,
                  child: CalendarDatePicker(
                    initialDate: temp,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (d) => temp = d,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: colorSchemeLocal.primary.withOpacity(0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: colorSchemeLocal.primary,
                        ),
                        onPressed: () => Navigator.of(dCtx).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: colorSchemeLocal.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () => Navigator.of(dCtx).pop(temp),
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Confirmation dialog ----------
  void _showConfirmationDialog(ReportType type, DateTimeRangeEntity dateRange) {
    final recommendedFormat = controller.getRecommendedFormat(type);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dCtx) {
        final colorScheme = Theme.of(dCtx).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: recommendedFormat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    recommendedFormat.icon,
                    size: 30,
                    color: recommendedFormat.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Confirmar Generación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Generar reporte de ${type.label} en formato ${recommendedFormat.label}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Período seleccionado:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRange.formattedForDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: colorScheme.primary.withOpacity(0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () => Navigator.of(dCtx).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () {
                          Navigator.of(dCtx).pop();
                          _generateReportWithLoading(type, dateRange);
                        },
                        child: const Text(
                          'Generar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Generate with loading ----------
  Future<void> _generateReportWithLoading(
    ReportType type,
    DateTimeRangeEntity dateRange,
  ) async {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() {
              final p = controller.currentProgress.value;
              final percent = (p * 100).toInt();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: p > 0 ? p : null,
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Generando Reporte...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor espera, esto puede tardar unos segundos',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (p >= 0.8)
                    Text(
                      'Procesando datos...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    ReportEntity? generated;
    try {
      generated = await controller.generateReport(
        type: type,
        dateRange: dateRange,
      );
      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      return;
    }

    try {
      await controller.downloadReport(generated);
    } catch (_) {
      // handled in controller
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
    }

  // ---------- Popup actions ----------
  void _handleReportAction(String action, ReportEntity report) {
    switch (action) {
      case 'download':
        controller.downloadReport(report).whenComplete(() {
          if (Get.isDialogOpen ?? false) Get.back();
        });
        break;
      case 'share':
        controller.shareReport(report);
        break;
      case 'delete':
        _showDeleteConfirmation(report);
        break;
    }
  }

  void _showDeleteConfirmation(ReportEntity report) {
    showDialog(
      context: context,
      builder: (dCtx) {
        final colorScheme = Theme.of(dCtx).colorScheme;

        // Intentamos mostrar el período guardado en data.period.display si existe
        String periodDisplay = report.dateRange;
        try {
          final p = report.data['period'];
          if (p is Map && p['display'] != null) {
            periodDisplay = p['display'].toString();
          }
        } catch (_) {}

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono / círculo
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),

                // Título
                Text(
                  'Eliminar Reporte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle (titulo del reporte y periodo)
                Text(
                  report.titleForUI,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  periodDisplay,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Mensaje
                Text(
                  '¿Estás seguro de que deseas eliminar este reporte? Esta acción no se puede deshacer.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // Botones: Cancelar (Outlined) y Eliminar (filled rojo)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: colorScheme.primary.withOpacity(0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () => Navigator.of(dCtx).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          // cerramos diálogo primero para mejorar UX y luego ejecutamos la eliminación
                          Navigator.of(dCtx).pop();
                          controller.deleteReport(report);
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Utilities ----------
  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
