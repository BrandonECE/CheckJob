import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MySettingsView extends StatelessWidget {
  const MySettingsView({super.key});

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
              _buildSettingsList(context),
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
          'Configuración',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          _settingsSection(context, 'Empresa', [
            _settingsItem(context, 'Información de la Empresa', Icons.business),
            _settingsItem(context, 'Datos Fiscales', Icons.receipt_long),
            _settingsItem(context, 'Logo y Branding', Icons.image),
          ]),
          const SizedBox(height: 20),
          _settingsSection(context, 'Sistema', [
            _settingsItem(context, 'Preferencias Generales', Icons.settings),
            _settingsItem(context, 'Notificaciones', Icons.notifications),
            _settingsItem(context, 'Seguridad', Icons.security),
          ]),
          const SizedBox(height: 20),
          _settingsSection(context, 'Facturación', [
            _settingsItem(context, 'Configuración de Facturas', Icons.receipt),
            _settingsItem(context, 'Impuestos', Icons.attach_money),
            _settingsItem(context, 'Métodos de Pago', Icons.payment),
          ]),
          const SizedBox(height: 20),
          _settingsSection(context, 'Avanzado', [
            _settingsItem(context, 'Base de Datos', Icons.storage),
            _settingsItem(context, 'Respaldos', Icons.backup),
            _settingsItem(context, 'Logs del Sistema', Icons.list_alt, callBack: () => Get.toNamed(Routes.myAuditLogsView),),
          ]),
        ],
      ),
    );
  }

  Widget _settingsSection(BuildContext context, String title, List<Widget> items) {
    return AbsorbPointer(
      absorbing: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _settingsItem(BuildContext context, String title, IconData icon, {VoidCallback? callBack}) {
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
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
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