// lib/presentation/views/my_material_portal_view.dart
import 'package:check_job/presentation/controllers/material/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyMaterialPortalView extends StatefulWidget {
  const MyMaterialPortalView({super.key});

  @override
  State<MyMaterialPortalView> createState() => _MyMaterialPortalViewState();
}

class _MyMaterialPortalViewState extends State<MyMaterialPortalView> {
  final MaterialController controller = Get.find<MaterialController>();
  late TextEditingController currentStockController;
  late TextEditingController minStockController;

  @override
  void initState() {
    super.initState();
    _loadMaterialData();
  }

  void _loadMaterialData() {
    final material = controller.selectedMaterial.value;
    currentStockController = TextEditingController();
    minStockController = TextEditingController();
    
    if (material != null) {
      currentStockController.text = material.currentStock.toString();
      minStockController.text = material.minStock.toString();
    }
  }

  @override
  void dispose() {
    currentStockController.dispose();
    minStockController.dispose();
    super.dispose();
  }

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
              _buildMaterialInfo(context),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildEditForm(context),
                ),
              ),
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
          'Det. Material',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }

  Widget _buildMaterialInfo(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Obx(() {
      final material = controller.selectedMaterial.value;
      if (material == null) {
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
              'Material no encontrado',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
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
              backgroundColor: color.withOpacity(0.1),
              child: Icon(Icons.inventory_2, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('Unidad: ${material.unit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('Estado: ${material.status}', style: TextStyle(fontSize: 12, color: material.statusColor)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEditForm(BuildContext context) {
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
      child: Column(
        children: [
          _buildNumberField(
            controller: currentStockController,
            label: 'Cantidad Actual',
            icon: Icons.numbers,
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            controller: minStockController,
            label: 'Stock Mínimo',
            icon: Icons.warning,
          ),
          const SizedBox(height: 20),
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _updateMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.save, color: Colors.white, size: 20),
          label: const Text(
            'Guardar Cambios',
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

  Widget _buildDeleteButton(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
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
          onPressed: _deleteMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
          label: const Text(
            'Eliminar Material',
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

  void _updateMaterial() {
    final material = controller.selectedMaterial.value;
    if (material == null) {
      Get.snackbar(
        'Error',
        'No se encontró el material',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final currentStock = int.tryParse(currentStockController.text) ?? 0;
    final minStock = int.tryParse(minStockController.text) ?? 0;

    if (currentStock < 0) {
      Get.snackbar(
        'Error',
        'La cantidad actual no puede ser negativa',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (minStock < 0) {
      Get.snackbar(
        'Error',
        'El stock mínimo no puede ser negativo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.updateMaterial(
      materialID: material.materialID,
      currentStock: currentStock,
      minStock: minStock,
    );
  }

  void _deleteMaterial() {
    final material = controller.selectedMaterial.value;
    if (material == null) {
      Get.snackbar(
        'Error',
        'No se encontró el material',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

   Get.defaultDialog(
    backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.only(top: 30),
      contentPadding: const EdgeInsets.only(top: 20, right: 30, bottom: 30, left: 30),
      title: 'Eliminar Material',
      middleText:
          '¿Estás seguro de que deseas eliminar "${material.name}"? Esta acción no se puede deshacer.',
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), // 👈 más padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          controller.deleteMaterial(material.materialID, material.name);
          Get.back(); // para cerrar el diálogo después
        },
        child: const Text('Eliminar'),
      ),
      cancel: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), // 👈 más padding
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