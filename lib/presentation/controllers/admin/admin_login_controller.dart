// lib/presentation/controllers/admin_login_controller.dart
import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';

class AdminLoginController extends GetxController {
  final AdminController _adminController;

  AdminLoginController({required AdminController adminController})
    : _adminController = adminController;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final email = emailController.text.trim();
      final password = passwordController.text;

      // Validaciones básicas
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Por favor completa todos los campos';
        return;
      }

      if (!email.isEmail) {
        errorMessage.value = 'Por favor ingresa un email válido';
        return;
      }

      await _adminController.login(email, password);

      if (_adminController.isAdminLoggedIn) {
        emailController.text = '';
        passwordController.text = '';
        Get.offAllNamed(Routes.myAdminPanelView);
      } else {
        errorMessage.value = 'Credenciales inválidas o no eres administrador';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
