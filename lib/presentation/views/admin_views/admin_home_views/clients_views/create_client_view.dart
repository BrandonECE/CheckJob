import 'package:check_job/presentation/controllers/client/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCreateClientView extends StatelessWidget {
  MyCreateClientView({super.key});

  final ClientController controller = Get.find<ClientController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
                      _buildAvatarSection(context),
                      const SizedBox(height: 24),
                      _buildFormSection(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCreateButton(context),
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
          'Crear Cliente',
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

  Widget _buildAvatarSection(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            'C',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cliente',
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
          label: 'Nombre del Cliente',
          hintText: 'Ingresa el nombre completo',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: emailController,
          label: 'Email',
          hintText: 'cliente@empresa.com',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: phoneController,
          label: 'Teléfono',
          hintText: '+1234567890',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
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

  Widget _buildCreateButton(BuildContext context) {
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
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator()),
          ),
        );
      }

      

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _createClient,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
          label: const Text(
            'Crear Cliente',
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

  void _createClient() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del cliente es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (email.isEmpty || !email.isEmail) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un email válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'El teléfono es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.createClient(
      name: name,
      email: email,
      phone: phone,
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}