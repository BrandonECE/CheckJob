import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/presentation/controllers/client/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyClientPortalView extends StatelessWidget {
  MyClientPortalView({super.key});

  final ClientController controller = Get.find<ClientController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.changeLoadingValue(false);
      },
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
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
        const SizedBox(width: 81),
      ],
    );
  }

  Widget _buildClientInfo(BuildContext context) {
    return Obx(() {
      final client = controller.selectedClient.value;
      if (client == null) {
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
          child: Center(
            child: Text(
              'Cliente no encontrado',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ),
        );
      }
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
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    client.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTasksList(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tareas del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final tasks = controller.selectedClientTasks;

            if (tasks.isEmpty) {
              return const Expanded(
                child: Center(
                  child: Text(
                    'No hay tareas para este cliente',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _taskCard(context, tasks[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _taskCard(BuildContext context, TaskEntity task) {
    Color statusColor = Colors.grey;
    String statusText = 'Pendiente';

    if (task.status == 'completed') {
      statusColor = Colors.green;
      statusText = 'Completado';
    } else if (task.status == 'in_progress') {
      statusColor = task.clientFeedback == null ? Colors.orange : Colors.blue;
      statusText = task.clientFeedback == null ? 'En Proceso' : 'En Revisión';
    }

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
                Text(
                  task.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${task.taskID}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  'Estado: $statusText',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  'Feedback: ${task.clientFeedback == null ? 'Pendiente' : 'Enviado'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
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
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Obx(() {
      if (controller.isButtonDeleteLoading.value) {
        return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: (){},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          label: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: Colors.grey.shade300, )),
        ),
      );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed:()=> _deleteClient(context),
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
    });
  }

  void _deleteClient(BuildContext context) {
    final client = controller.selectedClient.value;
    if (client == null) {
      Get.snackbar(
        'Error',
        'No se encontró el cliente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.defaultDialog(
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.only(top: 30),
      contentPadding: const EdgeInsets.only(
        top: 20,
        right: 30,
        bottom: 30,
        left: 30,
      ),
      title: 'Eliminar Cliente',
      middleText:
          '¿Estás seguro de que deseas eliminar "${client.name}"? Esta acción no se puede deshacer.',
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          controller.deleteClient(client.clientID, client.name);
          Get.back();
        },
        child: const Text('Eliminar'),
      ),
      cancel: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => Get.back(),
        child: const Text('Cancelar'),
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
