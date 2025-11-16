// integration_test/admin_login_flow_test.dart
import 'package:check_job/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Admin Login Flow',

    ($) async {
      // 1️⃣ Arranca la app
      app.main();
      await $.pumpAndSettle();

      // 2️⃣ Verifica que estamos en MyTaskLookUpView
      expect(find.text('Consultar Trabajos'), findsOneWidget);

      // 3️⃣ Toca el badge de Admin
      final adminBadge = find.text('Admin');
      expect(adminBadge, findsOneWidget);
      await $.tap(adminBadge);
      await $.pumpAndSettle();

      // 4️⃣ Verifica que se abrió MyAdminLoginView
      expect(find.text('Inicio de Sesión\nAdministrador'), findsOneWidget);

      // 5️⃣ Llena los campos con las credenciales
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Usuario (Email)',
      );
      final passwordField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Contraseña',
      );

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      await $.enterText(emailField, 'admin@checkjob.com');
      await $.enterText(passwordField, '123@ro');

      // 6️⃣ Toca el botón de login
      final loginButton = find.text('Iniciar Sesión');
      expect(loginButton, findsOneWidget);
      await $.tap(loginButton);

      // 7️⃣ Espera animación de loading y navegación
      await $.pump(); // inicia animación del loading
      await $.pump(const Duration(seconds: 2)); // espera un poco
      await $.pumpAndSettle(); // espera a que termine todo

      final adminPanel = find.byKey(Key('admin_panel'));
      await $.pumpAndSettle();

      expect(adminPanel, findsOneWidget);


    },
  );
}
