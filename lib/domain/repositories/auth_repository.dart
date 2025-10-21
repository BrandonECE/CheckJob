// lib/domain/repositories/auth_repository.dart
import 'package:check_job/domain/entities/admin_entity.dart';

abstract class AuthRepository {
  Future<AdminEntity?> loginAdmin(String email, String password);
  Future<void> logout();
  bool isAdminLoggedIn();
  String? getCurrentAdminId();
  AdminEntity? getCurrentAdmin();
  Stream<String?> get authStateChanges;
}