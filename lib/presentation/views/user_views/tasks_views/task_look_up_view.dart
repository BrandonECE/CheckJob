import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyTaskLookUpView extends StatelessWidget {
  const MyTaskLookUpView({super.key});

  @override
  Widget build(BuildContext context) {
    // tamaños proporcionales (ajústalos aquí si quieres escalar todo)
    const double avatarInnerSize = 90.0; // tamaño interior del círculo blanco
    const double ringPadding = 6.0; // padding del anillo exterior
    final double dotSize =
        avatarInnerSize * 0.21; // tamaño proporcional del punto verde

    return _myBody(avatarInnerSize, ringPadding, dotSize);
  }

  Scaffold _myBody(double avatarInnerSize, double ringPadding, double dotSize) {
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
                        // Top-right badge
                        _buildAdminBadge(context),

                        const SizedBox(height: 81),

                        // Título + logo
                        _buildTitleAndLogo(
                          context,
                          avatarInnerSize,
                          ringPadding,
                          dotSize,
                        ),

                        const SizedBox(height: 60),

                        // Campo de texto
                        _buildSearchField(context),

                        const SizedBox(height: 23),

                        // Botón Buscar
                        _buildSearchButton(context),

                        const SizedBox(height: 29),

                        // Microcopy ejemplo
                        _buildExampleRow(context),

                        const Spacer(),

                        // Footer
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

  // -----------------------
  // Widgets como funciones
  // -----------------------

  Widget _buildAdminBadge(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.myAdminLoginView),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  backgroundColor: Color(0xFFB71C1C),
                  radius: 10,
                  child: Icon(Icons.shield, size: 12, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndLogo(
    BuildContext context,
    double avatarInnerSize,
    double ringPadding,
    double dotSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Consultar Trabajos',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary, // usa primary del color scheme
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        const Text(
          'Introduce el ID del trabajo \npara ver su estado.',
          style: TextStyle(color: Colors.black87, fontSize: 13.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        // Logo con anillo y puntito verde
        Stack(
          alignment: Alignment.center,
          children: [
            _buildLogoRing(context, avatarInnerSize, ringPadding),
            Positioned(
              right: ringPadding + (dotSize * 0.1),
              bottom: ringPadding + (dotSize * 0.1),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.green.shade600, // parecido al 0xFF4CAF50
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoRing(
    BuildContext context,
    double avatarInnerSize,
    double ringPadding,
  ) {
    // aquí jugamos con opacidades para replicar el degradado original
    final colorScheme = Theme.of(context).colorScheme;

    // colores del degradado basados en primary con distintas opacidades
    final Color gradStart = colorScheme.primary.withOpacity(0.5); // más visible
    final Color gradEnd = colorScheme.primary.withOpacity(0.05); // sutil

    return Container(
      padding: EdgeInsets.all(ringPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradStart, gradEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        width: avatarInnerSize,
        height: avatarInnerSize,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(Icons.person, size: 40, color: colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Ingrese ID de Trabajo',
            prefixIcon: Icon(Icons.work_outline),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // jugamos con opacidades y una variación para dar un efecto similar al gradiente original
    final Color start = colorScheme.primary;
    final Color end = colorScheme.primary.withOpacity(0.85);

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.myUserTaskDetailView);
      },
      child: Container(
        height: 64,
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
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Buscar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          'Ejemplo de ID: 8A3F-221',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        'Interfaz de consulta de trabajos • Acceso de administrador disponible',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
