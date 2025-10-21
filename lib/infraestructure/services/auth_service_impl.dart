// lib/data/services/auth_service_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/auth_service.dart';
import 'package:check_job/domain/entities/admin_entity.dart';

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  AdminEntity? _currentAdmin;

  AuthServiceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

 // lib/data/services/auth_service_impl.dart
// lib/data/services/auth_service_impl.dart
// lib/data/services/auth_service_impl.dart
@override
Future<AdminEntity?> loginAdmin(String email, String password) async {
  try {
    final adminDoc = await _firestore
        .collection('admins')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get(GetOptions(source: Source.server));

    if (adminDoc.docs.isEmpty) {
      return Future.error('No tienes permisos de administrador');
    }

    final UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (userCredential.user != null) {
      final adminData = adminDoc.docs.first.data();
      _currentAdmin = AdminEntity.fromFirestore(adminData);
      return _currentAdmin;
    }

    return Future.error('Error desconocido durante el login');
  } on FirebaseAuthException catch (e) {
    return Future.error(_handleAuthException(e));
  } catch (e) {
    if (e is String) {
      return Future.error(e);
    }
    return Future.error('Error de autenticación: $e');
  }
}


  @override
  Future<void> logout() async {
    _currentAdmin = null;
    await _firebaseAuth.signOut();
  }

  @override
  bool isAdminLoggedIn() {
    return _firebaseAuth.currentUser != null && _currentAdmin != null;
  }

  @override
  String? getCurrentAdminId() {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  AdminEntity? getCurrentAdmin() {
    return _currentAdmin;
  }

  @override
  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) _currentAdmin = null;
      return user?.uid;
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un administrador con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta cuenta de administrador ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}