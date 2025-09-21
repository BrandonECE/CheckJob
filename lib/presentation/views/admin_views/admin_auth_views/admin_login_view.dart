import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyAdminLoginView extends StatelessWidget {
  const MyAdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return _myBody();
  }

  Scaffold _myBody() {
    return Scaffold(
      body: SafeArea(
        // Mantener footer abajo y permitir scroll cuando haga falta
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
                        // (opcional) top-right small badge / back
                        _buildTopRightBack(context),

                        const SizedBox(height: 37),

                        // Título principal + avatar con anillo
                        _buildTitleAndAvatar(context),

                        const SizedBox(height: 31),

                        // Campos usuario / contraseña
                        _buildFieldsGroup(context),

                        const SizedBox(height: 30),

                        // Botón Iniciar Sesión (full width)
                        _buildLoginButton(context),

                        const SizedBox(height: 29),

                        // Microcopy ayuda
                        _buildHelpRow(context),

                        const Spacer(),

                        // Footer siempre abajo
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

  // --- Top right back / small badge (igual que antes, pero usando colorScheme) ---
  Widget _buildTopRightBack(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        // deja onTap null por ahora (placeholder). Si quieres navegar, reemplaza por: () => Navigator.of(context).maybePop()
        onTap: () => Get.toNamed(Routes.myTaskLookUpView),
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
            color: colorScheme.primary, // usa primary del tema
          ),
        ),
      ),
    );
  }

  // --- Título y avatar con anillo degradado + badge decorativo ---
  Widget _buildTitleAndAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Tamaños similares a tu versión original
    const double avatarSize = 88.0;
    const double ringPadding = 6.0;
    const double smallBadgeSize = 22.0;

    return Column(
      children: [
        Text(
          'Inicio de Sesión\nAdministrador',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary, // usa primary del tema
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

        // Avatar con anillo y pequeño badge decorativo
        Container(
          padding: const EdgeInsets.all(ringPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // se juegan opacidades del primary para el anillo (efecto sutil)
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
              // círculo interior blanco con icono de shield rojo (error del tema si prefieres)
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
                      color: Theme.of(
                        context,
                      ).colorScheme.error, // rojo del tema (antes: 0xFFB71C1C)
                    ),
                  ),
                ),
              ),

              // pequeño badge decorativo abajo-derecha (usa primary como antes)
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

  // --- Grupo de campos: usuario y contraseña (reutiliza un helper) ---
  Widget _buildFieldsGroup(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          hint: 'Usuario',
          prefix: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hint: 'Contraseña',
          prefix: const Icon(Icons.lock_outline),
          obscure: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    Widget? prefix,
    bool obscure = false,
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
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // --- Botón Iniciar Sesión (full width) ---
  Widget _buildLoginButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color start = colorScheme.primary;
    final Color end = colorScheme.primary.withOpacity(0.85);

    return GestureDetector(
      onTap: () {
        Get.offAllNamed(Routes.myAdminPanelView);
      },
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
  }

  // --- Microcopy / ayuda ---
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

  // --- Footer ---
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
