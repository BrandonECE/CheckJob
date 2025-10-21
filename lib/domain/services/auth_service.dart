// lib/domain/services/auth_service.dart
import 'package:check_job/domain/entities/admin_entity.dart';

abstract class AuthService {
  Future<AdminEntity?> loginAdmin(String email, String password);
  Future<void> logout();
  bool isAdminLoggedIn();
  String? getCurrentAdminId();
  AdminEntity? getCurrentAdmin();
  Stream<String?> get authStateChanges;
}