import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/presentation/controllers/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDashboardView extends StatelessWidget {
  const MyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 20),
              _buildStatsGrid(context, controller),
              const SizedBox(height: 20),
              _buildRecentActivities(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 48,
      child: Row(
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
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.7,),
                  ),
              )
              : IconButton(
                  icon: Icon(Icons.refresh, color: color),
                  onPressed: () => controller.refreshDashboard(),
                )),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardController controller) {
    return Obx(() => GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      children: [
        _statCard(
          context, 
          'Tareas Activas', 
          controller.pendingTasksCount.value.toString(), 
          Icons.pending_actions, 
          Colors.orange
        ),
        _statCard(
          context, 
          'Tareas Completadas', 
          controller.completedTasksCount.value.toString(), 
          Icons.check_circle, 
          Colors.green
        ),
        _statCard(
          context, 
          'Clientes Activos', 
          controller.activeClientsCount.value.toString(), 
          Icons.people, 
          Colors.blue
        ),
        _statCard(
          context, 
          'Ingresos Mensuales', 
          '\$${controller.monthlyIncome.value.toStringAsFixed(2)}', 
          Icons.attach_money, 
          Colors.purple
        ),
      ],
    ));
  }

Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
  final isLoading = Get.find<DashboardController>().isLoading.value;
  
  return Container(
    padding: const EdgeInsets.all(12),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Text(
                  key: ValueKey(value),
                  value, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                ),
        ),
      ],
    ),
  );
}
  Widget _buildRecentActivities(BuildContext context, DashboardController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente', 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            )
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              
              if (controller.recentActivities.isEmpty) {
                return _buildEmptyState(context);
              }
              
              return ListView.builder(
                itemCount: controller.recentActivities.length,
                itemBuilder: (context, index) {
                  final task = controller.recentActivities[index];
                  return _activityItem(context, task);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando actividades...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay actividades recientes',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las tareas de la última semana aparecerán aquí',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _activityItem(BuildContext context, TaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(task.status), 
              size: 18, 
              color: _getStatusColor(task.status)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTitle(task.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.taskID} - ${task.title}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente: ${task.clientName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getTimeAgo(task.createdAt.toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(task.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(task.status),
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

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Colors.green;
    if (lowerStatus.contains('in_progress') || lowerStatus.contains('progress')) return Colors.orange;
    if (lowerStatus.contains('pending')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Icons.check_circle;
    if (lowerStatus.contains('in_progress') || lowerStatus.contains('progress')) return Icons.autorenew;
    if (lowerStatus.contains('pending')) return Icons.pending;
    return Icons.assignment;
  }

  String _getActivityTitle(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return 'Tarea completada';
    if (lowerStatus.contains('in_progress') || lowerStatus.contains('progress')) return 'Tarea en progreso';
    if (lowerStatus.contains('pending')) return 'Tarea pendiente';
    return 'Tarea actualizada';
  }

  String _getStatusText(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return 'Completada';
    if (lowerStatus.contains('in_progress') || lowerStatus.contains('progress')) return 'En Progreso';
    if (lowerStatus.contains('pending')) return 'Pendiente';
    return status;
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}