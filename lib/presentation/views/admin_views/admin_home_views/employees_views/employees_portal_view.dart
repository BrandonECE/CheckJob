import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyEmployeePortalView extends StatelessWidget {
  const MyEmployeePortalView({super.key});

  final List<Map<String, dynamic>> employeeTasks = const [
    {'id': 'TRAB-004', 'title': 'Instalación Sistema', 'status': 'Completado', 'date': '16 Nov 2023'},
    {'id': 'TRAB-005', 'title': 'Reparación Equipos', 'status': 'En Proceso', 'date': '19 Nov 2023'},
    {'id': 'TRAB-006', 'title': 'Mantenimiento Mensual', 'status': 'Pendiente', 'date': '21 Nov 2023'},
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
              _buildEmployeeInfo(context),
              const SizedBox(height: 20),
              _buildTasksList(context),
              const SizedBox(height: 20),
              _buildDeleteButton(context),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Text(
          'Port. Empleado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 41,)
      ],
    );
  }

  Widget _buildEmployeeInfo(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Container(
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
          // Avatar con gradiente (igual que en la lista de empleados)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.5),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 24, color: Colors.teal),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carlos Méndez', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('carlos@empresa.com', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('+1234567890', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          // Estado Activo/Inactivo
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //   decoration: BoxDecoration(
          //     color: Colors.green.shade100,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     'Activo',
          //     style: TextStyle(
          //       color: Colors.green,
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tareas Asignadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: employeeTasks.length,
              itemBuilder: (context, index) {
                return _taskCard(context, employeeTasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(BuildContext context, Map<String, dynamic> task) {
    Color statusColor = Colors.green;
    if (task['status'] == 'En Proceso') statusColor = Colors.orange;
    if (task['status'] == 'Pendiente') statusColor = Colors.grey;

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
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.task, size: 20, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'], style: TextStyle(fontWeight: FontWeight.w600)),
                Text('ID: ${task['id']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Fecha: ${task['date']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task['status'],
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Lógica para eliminar el empleado
          Get.defaultDialog(
            title: 'Eliminar Empleado',
            middleText: '¿Estás seguro de que deseas eliminar este empleado? Esta acción no se puede deshacer.',
            textConfirm: 'Eliminar',
            textCancel: 'Cancelar',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              Get.snackbar(
                'Empleado Eliminado',
                'El empleado ha sido eliminado correctamente',
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
          'Eliminar Empleado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
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