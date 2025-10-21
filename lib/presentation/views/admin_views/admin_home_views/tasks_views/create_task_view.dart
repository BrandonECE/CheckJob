// lib/presentation/views/admin/my_create_task_view.dart
import 'package:check_job/presentation/controllers/material/material_controller.dart';
import 'package:check_job/presentation/controllers/task/admin_task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/presentation/controllers/client/client_controller.dart';
import 'package:check_job/presentation/controllers/employee/employee_controller.dart';

class MyCreateTaskView extends StatefulWidget {
  const MyCreateTaskView({super.key});

  @override
  State<MyCreateTaskView> createState() => _MyCreateTaskViewState();
}

class _MyCreateTaskViewState extends State<MyCreateTaskView> {
  final AdminTaskController _taskController = Get.find<AdminTaskController>();
  final ClientController _clientController = Get.find<ClientController>();
  final EmployeeController _employeeController = Get.find<EmployeeController>();
  final MaterialController _materialController = Get.find<MaterialController>();

  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  final List<Map<String, dynamic>> _usedMaterials = [];

  String? _selectedClientId;
  String? _selectedClientName;
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedStatus = 'pending';
  String? _selectedPaymentStatus = 'pending';

  final List<String> _statuses = ['pending', 'in_progress', 'completed'];
  final Map<String, String> _statusLabels = {
    'pending': 'Pendiente',
    'in_progress': 'En Proceso',
    'completed': 'Completado',
  };
  final List<String> _paymentStatuses = ['paid', 'pending'];

  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _clientController.refreshClients();
    _employeeController.refreshEmployees();
    _materialController.refreshMaterials();

    // Valor inicial: mañana
    _selectedDueDate = DateTime.now().add(const Duration(days: 1));
    _dueDateController.text = _formatShortDate(_selectedDueDate!);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    for (final material in _usedMaterials) {
      (material['qtyController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addMaterialRow() {
    setState(() {
      _usedMaterials.add({
        'materialID': null, // id interno del material (se enviará al crear)
        'materialName': null,
        'unit': 'Pzas',
        'currentStock': 0, // campo UI-only para comparación/validación
        'qtyController': TextEditingController(),
        'quantity': 0,
      });
    });
  }

  void _removeMaterialRow(int index) {
    setState(() {
      final ctrl = _usedMaterials[index]['qtyController'] as TextEditingController;
      ctrl.dispose();
      _usedMaterials.removeAt(index);
    });
  }

  Future<void> _saveTask() async {
    if (_referenceController.text.isEmpty) {
      Get.snackbar('Error', 'El código de referencia es obligatorio',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_titleController.text.isEmpty) {
      Get.snackbar('Error', 'El título es obligatorio',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_selectedClientId == null) {
      Get.snackbar('Error', 'Debe seleccionar un cliente',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_selectedEmployeeId == null) {
      Get.snackbar('Error', 'Debe seleccionar un empleado',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validamos y ensamblamos materiales: cada fila debe tener materialID y cantidad > 0
    final List<Map<String, dynamic>> materialsData = [];
    for (final material in _usedMaterials) {
      final qtyText = (material['qtyController'] as TextEditingController).text.trim();
      final qty = int.tryParse(qtyText) ?? 0;
      final matId = material['materialID'] as String?;
      final matName = material['materialName'] as String?;
      final currentStock = material['currentStock'] is int ? material['currentStock'] as int : 0;

      if (matId == null || matId.isEmpty) {
        Get.snackbar('Error', 'Selecciona un material válido en todas las filas',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (qty <= 0) {
        Get.snackbar('Error', 'Ingresa una cantidad válida para ${matName ?? 'el material'}',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (currentStock < qty) {
        // Mensaje más informativo cuando falta stock (UI-only check)
        Get.snackbar(
          'Error',
          'Has pedido $qty unidades de "${matName ?? 'material'}" pero solo hay $currentStock disponibles.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      materialsData.add({
        'materialID': matId,
        'materialName': matName,
        'quantity': qty,
        'unit': material['unit'],
      });
    }

    await _taskController.createTask(
      taskId: _referenceController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      clientID: _selectedClientId!,
      clientName: _selectedClientName!,
      assignedEmployeeID: _selectedEmployeeId!,
      assignedEmployeeName: _selectedEmployeeName ?? '',
      status: _selectedStatus ?? 'pending',
      amount: double.tryParse(_amountController.text) ?? 0.0,
      dueDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      materialsUsed: materialsData,
    );
  }


  String _formatShortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickDueDate(BuildContext ctx) async {
    final DateTime initial = _selectedDueDate ?? DateTime.now().add(const Duration(days: 1));
    DateTime tempPicked = initial;

    final DateTime? picked = await showDialog<DateTime>(
      context: ctx,
      barrierDismissible: true,
      builder: (dialogCtx) {
        final colorScheme = Theme.of(dialogCtx).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'Seleccionar fecha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Calendar
                SizedBox(
                  height: 330,
                  child: CalendarDatePicker(
                    initialDate: tempPicked,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (d) => tempPicked = d,
                  ),
                ),

                const SizedBox(height: 18),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(null),
                        child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(tempPicked),
                        child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w600)),
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

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = _formatShortDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 15),
              _buildFormCard(context),
              const SizedBox(height: 16),
              _buildMaterialsSection(context),
              const SizedBox(height: 22),
              _buildSaveButton(context),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Panel administrativo • Gestión de tareas',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
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
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
          ),
        ),
        Text(
          'Crear Tarea',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 19),
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
          Text('Código de Referencia (ID)', style: labelStyle),
          const SizedBox(height: 8),
          Obx(
            () => _designTextField(
              context,
              controller: _referenceController,
              hint: 'Ej. T567U',
              errorText: _taskController.taskIdError.value.isNotEmpty
                  ? _taskController.taskIdError.value
                  : null,
              onChanged: (value) {
                if (value.length > 3) {
                  _taskController.checkTaskIdExists(value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Título de la tarea', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(
            context,
            controller: _titleController,
            hint: 'Ej. Revisión de motor',
          ),
          const SizedBox(height: 16),
          Text('Descripción del trabajo', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(
            context,
            controller: _descriptionController,
            hint: 'Detalles importantes, pasos o requerimientos',
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          Text('Cliente', style: labelStyle),
          const SizedBox(height: 8),
          Obx(() => _designClientDropdown(context)),
          const SizedBox(height: 16),
          Text('Empleado asignado', style: labelStyle),
          const SizedBox(height: 8),
          Obx(() => _designEmployeeDropdown(context)),
          const SizedBox(height: 16),
          Text('Estado inicial de la tarea', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(
            context,
            hint: 'Selecciona el estado',
            items: _statuses.map((status) => _statusLabels[status]!).toList(),
            values: _statuses,
            value: _selectedStatus,
            onChanged: (v) => setState(() => _selectedStatus = v),
          ),
          const SizedBox(height: 16),
          Text('Monto', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(
            context,
            controller: _amountController,
            hint: '\$0.00',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text('Estado de pago', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(
            context,
            hint: 'Selecciona estado de pago',
            items: const ['Pagado', 'Pendiente'],
            values: _paymentStatuses,
            value: _selectedPaymentStatus,
            onChanged: (v) => setState(() => _selectedPaymentStatus = v),
          ),
          const SizedBox(height: 16),
          Text('Fecha de vencimiento', style: labelStyle),
          const SizedBox(height: 8),

          // Campo readOnly con icono que abre el date picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                    controller: _dueDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onTap: () => _pickDueDate(context),
                  ),
                ),
                IconButton(
                  onPressed: () => _pickDueDate(context),
                  icon: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _designClientDropdown(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        value: _selectedClientId,
        items: _clientController.clients.map((client) {
          return DropdownMenuItem(
            value: client.clientID,
            child: Text(client.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (clientId) {
          setState(() {
            _selectedClientId = clientId;
            _selectedClientName = _clientController.clients.firstWhere((c) => c.clientID == clientId).name;
          });
        },
        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
          hintText: 'Elige un cliente',
        ),
      ),
    );
  }

  Widget _designEmployeeDropdown(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        value: _selectedEmployeeId,
        items: _employee_controller_items(),
        onChanged: (employeeId) {
          setState(() {
            _selectedEmployeeId = employeeId;
            _selectedEmployeeName = _employeeController.employees.firstWhere((e) => e.employeesID == employeeId).name;
          });
        },
        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
          hintText: 'Elige un empleado',
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _employee_controller_items() {
    return _employeeController.employees.map((employee) {
      return DropdownMenuItem(
        value: employee.employeesID,
        child: Text(employee.name, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  Widget _designTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primary),
            ),
            errorText: errorText,
          ),
        ),
        if (errorText != null) const SizedBox(height: 4),
      ],
    );
  }

  Widget _designDropdown(
    BuildContext context, {
    required String hint,
    required List<String> items,
    required List<String> values,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        value: value,
        items: List.generate(items.length, (index) {
          return DropdownMenuItem(
            value: values[index],
            child: Text(items[index], overflow: TextOverflow.ellipsis),
          );
        }),
        onChanged: onChanged,
        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(BuildContext context) {
    final smallTextStyle = TextStyle(fontSize: 13, color: Colors.grey.shade800);
    final hintStyle = TextStyle(fontSize: 13, color: Colors.grey.shade500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materiales a utilizar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_usedMaterials.length, (index) {
          final row = _usedMaterials[index];
          final TextEditingController qtyCtrl = row['qtyController'] as TextEditingController;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Material selector (value = materialID)
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    isExpanded: true,
                    value: row['materialID'] as String?,
                    items: _materialController.materials.map((material) {
                      return DropdownMenuItem(
                        value: material.materialID, // usamos materialID como value
                        child: Text(
                          material.name,
                          style: smallTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (selectedId) {
                      setState(() {
                        row['materialID'] = selectedId;
                        // rellenamos el nombre, la unidad y currentStock desde la lista de materiales seleccionada
                        try {
                          final found = _materialController.materials.firstWhere((m) => m.materialID == selectedId);
                          row['materialName'] = found.name;
                          // found.unit puede ser null o vacío dependiendo de tu entidad; lo manejamos
                          row['unit'] = (found.unit.isNotEmpty) ? found.unit : row['unit'];
                          // currentStock es sólo para validación en UI; no se envía al controller
                          row['currentStock'] = found.currentStock;
                        } catch (_) {
                          // si no se encuentra, dejamos lo que estaba
                        }
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Elige material',
                      hintStyle: hintStyle,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: smallTextStyle,
                  ),
                ),

                const SizedBox(width: 6),

                // Cantidad
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: smallTextStyle,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cantidad',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Unidad mostrada como texto estático (se actualiza cuando eliges material)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      row['unit']?.toString() ?? 'Pzas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                GestureDetector(
                  onTap: () => _removeMaterialRow(index),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                ),
              ],
            ),
          );
        }),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addMaterialRow,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Agregar material', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            if (_usedMaterials.isNotEmpty)
              Text('${_usedMaterials.length} agregado(s)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Obx(() {
      if (_taskController.isButtonLoading.value) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.save, color: Colors.white, size: 20),
          label: const Text(
            'Guardar tarea',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
    });
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
