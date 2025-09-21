import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyMaterialsView extends StatelessWidget {
  const MyMaterialsView({super.key});

  final List<Map<String, dynamic>> materials = const [
    {'name': 'Aceite Motor', 'stock': '42', 'unit': 'Lts', 'minStock': '10', 'status': 'Normal'},
    {'name': 'Filtro Aire', 'stock': '8', 'unit': 'Pzas', 'minStock': '15', 'status': 'Bajo'},
    {'name': 'Bujías', 'stock': '25', 'unit': 'Pzas', 'minStock': '20', 'status': 'Normal'},
    {'name': 'Pastillas Frenos', 'stock': '5', 'unit': 'Pzas', 'minStock': '8', 'status': 'Crítico'},
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(context, 'Total Items', '48', Icons.inventory),
        _statItem(context, 'Bajo Stock', '2', Icons.warning),
        _statItem(context, 'Crítico', '1', Icons.error),
      ],
    );
  }

  Widget _statItem(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: materials.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Get.toNamed(Routes.myMaterialPortalView),
            child: _materialCard(context, materials[index]));
        },
      ),
    );
  }

  Widget _materialCard(BuildContext context, Map<String, dynamic> material) {
    Color statusColor = Colors.green;
    if (material['status'] == 'Bajo') statusColor = Colors.orange;
    if (material['status'] == 'Crítico') statusColor = Colors.red;

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
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Stock: ${material['stock']} ${material['unit']}', 
                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Mínimo: ${material['minStock']}', 
                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
              material['status'],
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
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