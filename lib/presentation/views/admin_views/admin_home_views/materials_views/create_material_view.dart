// lib/presentation/views/my_create_material_view.dart
import 'package:check_job/presentation/controllers/material/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCreateMaterialView extends StatelessWidget {
  MyCreateMaterialView({super.key});

  final MaterialController controller = Get.find<MaterialController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentStockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final RxString selectedUnit = 'Lts'.obs;

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildIconSection(context),
                      const SizedBox(height: 24),
                      _buildFormSection(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildAddButton(context),
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
          'Añadir Material',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }

  Widget _buildIconSection(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            Icons.inventory_2,
            size: 40,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nuevo Material',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller: nameController,
          label: 'Nombre del Material',
          hintText: 'Ej: Aceite Motor, Filtro Aire, etc.',
          icon: Icons.inventory_2,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Tipo de Unidad',
          items: ['Lts', 'Pzas', 'Kg', 'Mts', 'Cm', 'Unidades'],
          icon: Icons.straighten,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: currentStockController,
          label: 'Cantidad Actual',
          hintText: '0',
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: minStockController,
          label: 'Stock Mínimo',
          hintText: '0',
          icon: Icons.warning,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              icon: Icon(icon, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
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
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedUnit.value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedUnit.value = newValue;
                }
              },
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
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
            child:  SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator()),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _createMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            'Añadir Material',
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

  void _createMaterial() {
    final name = nameController.text.trim();
    final currentStock = int.tryParse(currentStockController.text) ?? 0;
    final minStock = int.tryParse(minStockController.text) ?? 0;

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del material es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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

    controller.createMaterial(
      name: name,
      currentStock: currentStock,
      minStock: minStock,
      unit: selectedUnit.value,
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}