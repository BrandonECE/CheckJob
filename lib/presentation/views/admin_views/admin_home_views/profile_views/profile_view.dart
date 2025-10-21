// lib/presentation/views/my_profile_view.dart
import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/profile/profile_controller.dart';

class MyProfileView extends StatelessWidget {
  MyProfileView({super.key});

  final AdminController adminController = Get.find<AdminController>();
  final ProfileController profileController = Get.find<ProfileController>();

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
              _buildProfileCard(context),
              const SizedBox(height: 20),
              _buildProfileOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'Mi Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Obx(() => profileController.isLoading.value
              ? Padding(
                   padding: const EdgeInsets.only(left: 13, right: 15),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => profileController.refreshProfileStats(),
                )),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Obx(() {
      final admin = adminController.currentAdmin;
        final elapsedTime = admin != null
          ? _getElapsedTime(admin.createdAt)
          : {"Años": 0};
      final isLoading = profileController.isLoading.value;
      
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
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              admin != null ? admin.name : "User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              admin != null ? admin.email : "user@checkjob.com",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _profileStat(context, 'Tareas', profileController.totalTasksCount, isLoading),
                _profileStat(context, 'Clientes', profileController.totalClientsCount, isLoading),
                _profileStatStatic(
                  context, 
                  elapsedTime.keys.first, 
                  elapsedTime[elapsedTime.keys.first]!.toStringAsFixed(0),
                  isLoading
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _profileStat(BuildContext context, String label, RxInt value, bool isLoading) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isLoading
              ? Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 4),
                key: const ValueKey('loading'),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
              )
              : Text(
                  key: ValueKey(value.value),
                  value.value.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _profileStatStatic(BuildContext context, String label, String value, bool isLoading) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isLoading ? Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 4),
                key: const ValueKey('loading'),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ) :  Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Map<String, double> _getElapsedTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final days = difference.inDays.toDouble();
    final weeks = days / 7;
    final months = days / 30.44;
    final years = days / 365.25;

    if (years >= 1) {
      return {'Años': double.parse(years.toStringAsFixed(2))};
    } else if (months >= 1) {
      return {'Meses': double.parse(months.toStringAsFixed(2))};
    } else if (weeks >= 1) {
      return {'Semanas': double.parse(weeks.toStringAsFixed(2))};
    } else {
      return {'Días': double.parse(days.toStringAsFixed(2))};
    }
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          _profileOption(context, 'Información Personal', Icons.person_outline),
          _profileOption(context, 'Seguridad', Icons.security),
          _profileOption(
            context,
            'Preferencias',
            Icons.settings,
            callBack: () => Get.toNamed(Routes.mySettingsView),
          ),
          _profileOption(
            context,
            'Notificaciones',
            Icons.notifications,
            callBack: () => Get.toNamed(Routes.myNotificationsView),
          ),
          _profileOption(context, 'Ayuda y Soporte', Icons.help),
          _profileOption(
            context,
            'Cerrar Sesión',
            Icons.exit_to_app,
            isLogout: true,
            callBack: _logout,
          ),
        ],
      ),
    );
  }

  Widget _profileOption(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLogout = false,
    VoidCallback? callBack,
  }) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
            Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? Colors.red : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Get.offAllNamed(Routes.myTaskLookUpView);
   adminController.logout();

  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}