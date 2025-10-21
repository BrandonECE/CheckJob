// lib/data/repositories/auth_repository_impl.dart
import 'package:check_job/domain/repositories/auth_repository.dart';
import 'package:check_job/domain/services/auth_service.dart';
import 'package:check_job/domain/entities/admin_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  Future<AdminEntity?> loginAdmin(String email, String password) async {
    try {
      return await _authService.loginAdmin(email, password);
    } catch (e) {
      // Podemos agregar lógica adicional de repositorio aquí si es necesario
      // Por ejemplo: logging, transformación de errores, etc.
      return Future.error(e);
    }
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  bool isAdminLoggedIn() {
    return _authService.isAdminLoggedIn();
  }

  @override
  String? getCurrentAdminId() {
    return _authService.getCurrentAdminId();
  }

  @override
  AdminEntity? getCurrentAdmin() {
    return _authService.getCurrentAdmin();
  }

  @override
  Stream<String?> get authStateChanges => _authService.authStateChanges;
}