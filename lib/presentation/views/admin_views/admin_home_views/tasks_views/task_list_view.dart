// lib/presentation/views/admin/my_task_list_view.dart
import 'package:check_job/config/routes.dart';
import 'package:check_job/presentation/controllers/task/admin_task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/enities.dart';

class MyTaskListView extends StatelessWidget {
  const MyTaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminTaskController controller = Get.find<AdminTaskController>();

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
              _buildSearchField(context),
              const SizedBox(height: 20),
              _buildTasksList(context, controller),
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
          'Lista de Tareas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.toNamed(Routes.myCreateTaskView),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (_) {},
              decoration: InputDecoration(
                hintText: 'Buscar tarea...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, AdminTaskController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.tasks.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('No hay tareas disponibles'),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: controller.tasks.length,
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            return GestureDetector(
              onTap: () {
                controller.selectTask(task);
              },
              child: _taskCard(context, task),
            );
          },
        ),
      );
    });
  }

  Widget _taskCard(BuildContext context, TaskEntity task) {
    Color statusColor = _statusColor(task.status);

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
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Cliente: ${task.clientName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'ID: ${task.taskID}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(task.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Colors.green;
    if (lowerStatus.contains('in_progress')) return Colors.orange;
    if (lowerStatus.contains('pending')) return Colors.grey;
    return Colors.blue;
  }

  String _formatStatus(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed') return 'Completado';
    if (lowerStatus == 'in_progress') return 'En Proceso';
    if (lowerStatus == 'pending') return 'Pendiente';
    return status;
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}