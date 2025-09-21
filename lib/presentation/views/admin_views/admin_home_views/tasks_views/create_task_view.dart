import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyCreateTaskView extends StatefulWidget {
  const MyCreateTaskView({super.key});

  @override
  State<MyCreateTaskView> createState() => _MyCreateTaskViewState();
}

class _MyCreateTaskViewState extends State<MyCreateTaskView> {
  // Datos de ejemplo
  static const List<String> _employees = ['Juan Pérez', 'María López', 'Carlos Rodríguez'];
  static const List<String> _statuses = ['Pendiente', 'En proceso', 'Completado'];
  static const List<String> _clients = ['Empresa ABC', 'Compañía XYZ', 'Negocio 123'];
  static const List<String> _paymentStatuses = ['Pagado', 'Pendiente'];

  // Lista de materiales disponibles (puedes traerla del backend / MyMaterialsView)
  static const List<String> _availableMaterials = [
    'Aceite Motor',
    'Filtro Aire',
    'Bujías',
    'Pastillas Frenos'
  ];

  // Para los materiales usados en la tarea (cada elemento mantiene su controller)
  final List<Map<String, dynamic>> _usedMaterials = [];

  // Controllers para otros campos si los necesitas (ejemplo: referencia y título)
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  // Dropdown selecteds (solo si quieres valores iniciales manejados aquí)
  String? _selectedClient;
  String? _selectedEmployee;
  String? _selectedStatus;
  String? _selectedPaymentStatus;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 26, vertical: 20);

  @override
  void dispose() {
    // dispose controllers
    _referenceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();

    for (final e in _usedMaterials) {
      (e['qtyController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addMaterialRow() {
    setState(() {
      _usedMaterials.add({
        'material': null, // nombre seleccionado
        'unit': 'Pzas', // unidad por defecto
        'qtyController': TextEditingController(),
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottomPadding = 12.0 + bottomInset;

    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      // resizeToAvoidBottomInset default true; mantenemos
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            // importante: agregar padding bottom con viewInsets para evitar overflow
            padding: EdgeInsets.only(bottom: safeBottomPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // un pequeño espacio extra para que el contenido no quede pegado al borde
                    SizedBox(height: 12 + bottomInset),
                  ],
                ),
              ),
            ),
          );
        }),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
          ),
        ),
        Text(
          'Crear Tarea',
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final labelStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID
          Text('Código de Referencia (ID)', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(context, controller: _referenceController, hint: 'Ej. T567U'),

          const SizedBox(height: 16),

          // Título
          Text('Título de la tarea', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(context, controller: _titleController, hint: 'Ej. Revisión de motor'),

          const SizedBox(height: 16),

          // Descripción
          Text('Descripción del trabajo', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(context, controller: _descriptionController, hint: 'Detalles importantes, pasos o requerimientos', minLines: 3, maxLines: 6),

          const SizedBox(height: 16),

          // Cliente
          Text('Cliente', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(context, hint: 'Elige un cliente', items: _clients, value: _selectedClient, onChanged: (v) => setState(() => _selectedClient = v)),

          const SizedBox(height: 16),

          // Empleado asignado
          Text('Empleado asignado', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(context, hint: 'Elige un empleado', items: _employees, value: _selectedEmployee, onChanged: (v) => setState(() => _selectedEmployee = v)),

          const SizedBox(height: 16),

          // Estado inicial
          Text('Estado inicial de la tarea', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(context, hint: 'Selecciona el estado', items: _statuses, value: _selectedStatus, onChanged: (v) => setState(() => _selectedStatus = v)),

          const SizedBox(height: 16),

          // Monto
          Text('Monto', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(context, controller: _amountController, hint: '\$0.00', keyboardType: TextInputType.number),

          const SizedBox(height: 16),

          // Estado de pago
          Text('Estado de pago', style: labelStyle),
          const SizedBox(height: 8),
          _designDropdown(context, hint: 'Selecciona estado de pago', items: _paymentStatuses, value: _selectedPaymentStatus, onChanged: (v) => setState(() => _selectedPaymentStatus = v)),

          const SizedBox(height: 16),

          // Fecha de vencimiento
          Text('Fecha de vencimiento', style: labelStyle),
          const SizedBox(height: 8),
          _designTextField(context, controller: _dueDateController, hint: 'DD/MM/AAAA'),
        ],
      ),
    );
  }

  Widget _designTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary)),
      ),
    );
  }

  Widget _designDropdown(BuildContext context, {required String hint, required List<String> items, String? value, required ValueChanged<String?> onChanged}) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
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

  // Sección: materiales usados (ajustada para evitar overflow horizontal)
  Widget _buildMaterialsSection(BuildContext context) {
    final smallTextStyle = TextStyle(fontSize: 13, color: Colors.grey.shade800);
    final hintStyle = TextStyle(fontSize: 13, color: Colors.grey.shade500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Materiales a utilizar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 8),

        // Lista de filas de materiales añadidos
        ...List.generate(_usedMaterials.length, (index) {
          final row = _usedMaterials[index];
          final TextEditingController qtyCtrl = row['qtyController'] as TextEditingController;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                // Material selector - ocupa más espacio
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    isExpanded: true,
                    value: row['material'] as String?,
                    items: _availableMaterials
                        .map((m) => DropdownMenuItem(value: m, child: Text(m, style: smallTextStyle, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => row['material'] = v),
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

                // Unidad
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    isExpanded: true,
                    value: row['unit'] as String?,
                    items: const [
                      DropdownMenuItem(value: 'Pzas', child: Text('Pzas')),
                      DropdownMenuItem(value: 'Lts', child: Text('Lts')),
                      DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                      DropdownMenuItem(value: 'm', child: Text('m')),
                    ],
                    onChanged: (v) => setState(() => row['unit'] = v),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                    style: smallTextStyle,
                  ),
                ),

                const SizedBox(width: 6),

                // boton eliminar (más pequeño)
                GestureDetector(
                  onTap: () => _removeMaterialRow(index),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                ),
              ],
            ),
          );
        }),

        // Botón para agregar más materiales
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addMaterialRow,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Agregar material', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
    final primary = Theme.of(context).colorScheme.primary;
    final start = primary;
    final end = primary.withOpacity(0.85);

    return GestureDetector(
      onTap: () {
        // Aquí podrías validar y enviar los datos.
        final used = _usedMaterials.map((m) {
          return {
            'material': m['material'],
            'qty': (m['qtyController'] as TextEditingController).text,
            'unit': m['unit'],
          };
        }).toList();

        // demo: print
        // ignore: avoid_print
        print('Saving task with materials: $used');
      },
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [start, end]),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: const Center(
          child: Text(
            'Guardar tarea',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16.5),
          ),
        ),
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
