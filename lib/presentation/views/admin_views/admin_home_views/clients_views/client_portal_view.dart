import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyClientPortalView extends StatelessWidget {
  const MyClientPortalView({super.key});

  final List<Map<String, dynamic>> clientTasks = const [
    {'id': 'TRAB-001', 'title': 'Mantenimiento Preventivo', 'status': 'Completado', 'date': '15 Nov 2023'},
    {'id': 'TRAB-002', 'title': 'Reparación Motor', 'status': 'En Proceso', 'date': '18 Nov 2023'},
    {'id': 'TRAB-003', 'title': 'Cambio de Aceite', 'status': 'Pendiente', 'date': '20 Nov 2023'},
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
              _buildClientInfo(context),
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
          'Port. Cliente',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 81,)
      ],
    );
  }

  Widget _buildClientInfo(BuildContext context) {
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
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text('E', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Empresa ABC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('contacto@abc.com', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('+1234567890', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mis Tareas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: clientTasks.length,
              itemBuilder: (context, index) {
                return _taskCard(context, clientTasks[index]);
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
          // Lógica para eliminar el cliente
          Get.defaultDialog(
            title: 'Eliminar Cliente',
            middleText: '¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer.',
            textConfirm: 'Eliminar',
            textCancel: 'Cancelar',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              Get.snackbar(
                'Cliente Eliminado',
                'El cliente ha sido eliminado correctamente',
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
          'Eliminar Cliente',
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