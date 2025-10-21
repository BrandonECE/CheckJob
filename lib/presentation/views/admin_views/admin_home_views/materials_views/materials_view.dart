// lib/presentation/views/my_materials_view.dart
import 'package:check_job/config/routes.dart';
import 'package:check_job/presentation/controllers/material/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/entities/enities.dart';

class MyMaterialsView extends StatelessWidget {
  MyMaterialsView({super.key});

  final MaterialController controller = Get.find<MaterialController>();

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
              _buildInventoryStats(context),
              const SizedBox(height: 20),
              _buildMaterialsList(context),
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
          'Materiales',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.toNamed(Routes.myCreateMaterialView),
        ),
      ],
    );
  }

  Widget _buildInventoryStats(BuildContext context) {
    return Obx(() {
      final stats = controller.getInventoryStats();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            context,
            'Total Items',
            stats['total'].toString(),
            Icons.inventory,
          ),
          _statItem(
            context,
            'Bajo Stock',
            stats['low'].toString(),
            Icons.warning,
          ),
          _statItem(
            context,
            'Crítico',
            stats['critical'].toString(),
            Icons.error,
          ),
        ],
      );
    });
  }

  Widget _statItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        AnimatedSwitcher(
                duration: const Duration(milliseconds: 120),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
          child: Text(
            key: ValueKey(value), 
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final materials = controller.materials;

      if (materials.isEmpty) {
        return const Expanded(
          child: Center(child: Text('No hay materiales registrados')),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                controller.selectMaterial(materials[index]);
                Get.toNamed(Routes.myMaterialPortalView);
              },
              child: _materialCard(context, materials[index]),
            );
          },
        ),
      );
    });
  }

  Widget _materialCard(BuildContext context, MaterialEntity material) {
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
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.inventory_2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Stock: ${material.currentStock} ${material.unit}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Mínimo: ${material.minStock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            layoutBuilder: (currentChild, previousChildren) {
                 return Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            
            },
            child: Container(
              key: ValueKey(material.status), // importante
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: material.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                material.status,
                style: TextStyle(
                  color: material.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
