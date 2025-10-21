// lib/presentation/views/my_admin_login_view.dart
import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/presentation/controllers/admin/admin_login_controller.dart';

class MyAdminLoginView extends StatelessWidget {
  MyAdminLoginView({super.key});

  final AdminLoginController controller = Get.find<AdminLoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTopRightBack(context),
                        const SizedBox(height: 37),
                        _buildTitleAndAvatar(context),
                        const SizedBox(height: 31),
                        _buildFieldsGroup(context),
                        const SizedBox(height: 30),
                        _buildLoginButton(context),
                        const SizedBox(height: 29),
                        _buildHelpRow(context),
                        const Spacer(),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopRightBack(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => Get.offAllNamed(Routes.myTaskLookUpView),
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
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double avatarSize = 88.0;
    const double smallBadgeSize = 22.0;

    return Column(
      children: [
        Text(
          'Inicio de Sesión\nAdministrador',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        const Text(
          'Accede con tus credenciales de administrador.',
          style: TextStyle(color: Colors.black87, fontSize: 13.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.5),
                colorScheme.primary.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 28,
                    child: Icon(
                      Icons.shield,
                      size: 36,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 6,
                child: Container(
                  width: smallBadgeSize,
                  height: smallBadgeSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.key, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsGroup(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.emailController,
          hint: 'Usuario (Email)',
          prefix: const Icon(Icons.person_outline),
          onChanged: (_) => controller.clearError(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.passwordController,
          hint: 'Contraseña',
          prefix: const Icon(Icons.lock_outline),
          obscure: true,
          onChanged: (_) => controller.clearError(),
        ),
        Obx(() => controller.errorMessage.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    bool obscure = false,
    ValueChanged<String>? onChanged,
  }) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color start = colorScheme.primary;
    final Color end = colorScheme.primary.withOpacity(0.85);

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.grey.shade300,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return GestureDetector(
        onTap: () => controller.login(),
        child: Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(colors: [start, end]),
            boxShadow: [
              BoxShadow(
                color: start.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16.5,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHelpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '¿Problemas para iniciar sesión?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        'Interfaz de administrador • Acceso restringido',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        textAlign: TextAlign.center,
      ),
    );
  }
}