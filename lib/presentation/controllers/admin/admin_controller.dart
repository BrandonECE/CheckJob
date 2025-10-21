// lib/presentation/controllers/admin_controller.dart
import 'package:get/get.dart';
import 'package:check_job/domain/entities/admin_entity.dart';
import 'package:check_job/domain/repositories/auth_repository.dart';

class AdminController extends GetxController {
  final AuthRepository _authRepository;

  final Rx<AdminEntity?> _currentAdmin = Rx<AdminEntity?>(null);
  final RxBool isLoading = false.obs;

  AdminController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  AdminEntity? get currentAdmin => _currentAdmin.value;
  bool get isAdminLoggedIn => _currentAdmin.value != null;

  @override
  void onInit() {
    _loadCurrentAdmin();
    super.onInit();
  }

  void _loadCurrentAdmin() {
    final admin = _authRepository.getCurrentAdmin();
    if (admin != null) {
      _currentAdmin.value = admin;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final admin = await _authRepository.loginAdmin(email, password);
      if (admin != null) {
        print(admin.adminID);
        _currentAdmin.value = admin;
      } else {
        return Future.error('Error desconocido durante el login');
      }
    } catch (e) {
      // Re-lanzar la excepción para que AdminLoginController la capture
      return Future.error(e);
    } finally {
      isLoading.value = false;
    }
  }

  void setAdmin(AdminEntity admin) {
    _currentAdmin.value = admin;
  }

    void _clearAdmin() {
    _currentAdmin.value = null;
  }

  Future<void> logout() async {
    isLoading.value = true;
    await _authRepository.logout();
    _clearAdmin();
    isLoading.value = false;
  }
}
