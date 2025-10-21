import 'package:check_job/config/routes.dart';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/presentation/controllers/client/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyClientsView extends StatelessWidget {
  MyClientsView({super.key});

  final ClientController controller = Get.find<ClientController>();

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
    final color = Theme.of(context).colorScheme.primary;
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
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
          ),
        ),
        Text(
          'Clientes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.toNamed(Routes.myCreateClientView),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (_) {},
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final clients = controller.clients;

      if (clients.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text(
              'No hay clientes registrados',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                await controller.selectClient(clients[index].clientID);
                Get.toNamed(Routes.myClientPortalView);
              },
              child: _clientCard(context, clients[index]),
            );
          },
        ),
      );
    });
  }

  Widget _clientCard(BuildContext context, ClientEntity client) {
    final isActive = client.isActive ?? false;
    
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
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    client.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600
                      ,overflow: TextOverflow.ellipsis
                    ),
                  ),
                ),
                Text(
                  client.phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
             
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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