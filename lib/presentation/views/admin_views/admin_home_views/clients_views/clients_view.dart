import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyClientsView extends StatelessWidget {
  const MyClientsView({super.key});

  final List<Map<String, dynamic>> clients = const [
    {
      'name': 'Empresa ABC',
      'email': 'contacto@abc.com',
      'phone': '+1234567890',
      'status': 'Activo',
    },
    {
      'name': 'Compañía XYZ',
      'email': 'info@xyz.com',
      'phone': '+0987654321',
      'status': 'Activo',
    },
    {
      'name': 'Negocio 123',
      'email': 'ventas@negocio123.com',
      'phone': '+1122334455',
      'status': 'Inactivo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchField(context),
              const SizedBox(height: 20),
              _buildClientsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
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
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Text(
          'Clientes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.toNamed(Routes.myCreateClientView),
        ),
      ],
    );
  }

  // Nuevo: buscador visual (solo diseño)
  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (_) {}, // diseño-only
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // botón visual para filtro/clear (no funcional)
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(Routes.myClientPortalView);
            },
            child: _clientCard(context, clients[index]),
          );
        },
      ),
    );
  }

  Widget _clientCard(BuildContext context, Map<String, dynamic> client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Text(
              client['name'][0],
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name'],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  client['email'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  client['phone'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: client['status'] == 'Activo'
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              client['status'],
              style: TextStyle(
                color: client['status'] == 'Activo'
                    ? Colors.green
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
