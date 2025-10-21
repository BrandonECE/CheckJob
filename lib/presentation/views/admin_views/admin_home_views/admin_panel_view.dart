import 'package:check_job/config/routes.dart';
import 'package:check_job/presentation/controllers/admin/admin_panel_controller.dart';
import 'package:check_job/presentation/controllers/notification/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAdminPanelView extends StatelessWidget {
  MyAdminPanelView({super.key});

  final List<Map<String, dynamic>> menuItems = const [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard,
      'route': Routes.myDashboardView,
    },
    {'title': 'Tareas', 'icon': Icons.task, 'route': Routes.myTaskListView},
    {
      'title': 'Empleados',
      'icon': Icons.people,
      'route': Routes.myEmployeesView,
    },
    {
      'title': 'Clientes',
      'icon': Icons.business,
      'route': Routes.myClientsView,
    },
    {
      'title': 'Materiales',
      'icon': Icons.inventory,
      'route': Routes.myMaterialsView,
    },
    {
      'title': 'Facturas',
      'icon': Icons.receipt,
      'route': Routes.myInvoicesView,
    },
    {
      'title': 'Reportes',
      'icon': Icons.analytics,
      'route': Routes.myReportsView,
    },
    {
      'title': 'Estadísticas',
      'icon': Icons.bar_chart,
      'route': Routes.myStatisticsView,
    },
    {
      'title': 'Config.',
      'icon': Icons.settings,
      'route': Routes.mySettingsView,
    },
  ];
  
  final NotificationController notificationController = Get.find<NotificationController>();
  final AdminPanelController adminController = Get.find<AdminPanelController>();

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
              _buildWelcomeCard(context),
              const SizedBox(height: 12),
              _buildProfileTile(context),
              const SizedBox(height: 20),
              _buildQuickStats(context),
              const SizedBox(height: 20),
              Expanded(child: _buildMenuGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final int notificationsCount = notificationController.notificaitonsCount.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pn. Control',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.myNotificationsView),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: null,
                ),
                Positioned(
                  right: 6,
                  top: 8,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 115),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    child: notificationsCount > 0 ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      width: notificationsCount > 9 ? 21.8 : 21.5,
                      height: notificationsCount > 9 ? 21.8 : 21.5,
                      child: Text(
                        notificationsCount > 9
                            ? "+9"
                            : notificationsCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ) : SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
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
            child: Icon(
              Icons.person,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido, Admin!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tu negocio de manera eficiente',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.myProfileView),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Perfil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ver y editar información de la cuenta',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Obx(() {
      final isLoading = adminController.isLoading.value;
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickStatItem(
            context, 
            isLoading ? '0' : adminController.pendingTasksCount.value.toString(), 
            'Pendientes', 
            Icons.pending, 
            Colors.blue,
            isLoading: isLoading,
          ),
          _quickStatItem(
            context, 
            isLoading ? '0' : adminController.inProgressTasksCount.value.toString(), 
            'En Proceso', 
            Icons.settings, 
            Colors.orange,
            isLoading: isLoading,
          ),
          _quickStatItem(
            context, 
            isLoading ? '0' : adminController.completedTasksCount.value.toString(), 
            'Completadas', 
            Icons.check_circle, 
            Colors.green,
            isLoading: isLoading,
          ),
        ],
      );
    });
  }

  Widget _quickStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color, {
    bool isLoading = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
        duration: const Duration(milliseconds: 120),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
       
          child:  isLoading
              ? Column(
                children: [
                  SizedBox(height: 4),
                  SizedBox(
                      key: ValueKey('loading_$label'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    SizedBox(height: 6,),
                ],
              )
              : Text(
                  key: ValueKey('value_$label'),
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 114.5,
        childAspectRatio: 0.9,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _menuItem(context, menuItems[index]);
      },
    );
  }

  Widget _menuItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Get.toNamed(item['route']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}