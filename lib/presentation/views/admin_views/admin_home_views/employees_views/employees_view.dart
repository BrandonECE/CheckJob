import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyEmployeesView extends StatelessWidget {
  MyEmployeesView({super.key});

  final List<Map<String, dynamic>> _sampleEmployees = [
    {
      'name': 'Carlos Méndez',
      'email': 'carlos@empresa.com',
      'phone': '+1234567890',
      'status': 'Activo',
    },
    {
      'name': 'Fernanda Torres',
      'email': 'fernanda@empresa.com',
      'phone': '+0987654321',
      'status': 'Activo',
    },
    {
      'name': 'Luis Pérez',
      'email': 'luis@empresa.com',
      'phone': '+1122334455',
      'status': 'Inactivo',
    },
    {
      'name': 'Mariana López',
      'email': 'mariana@empresa.com',
      'phone': '+4455667788',
      'status': 'Activo',
    },
    {
      'name': 'Sofía Rodríguez',
      'email': 'sofia@empresa.com',
      'phone': '+9988776655',
      'status': 'Inactivo',
    },
  ];

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 26, vertical: 28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: Padding(
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchField(context),
              const SizedBox(height: 20),
              Expanded(
                child: _buildEmployeesList(context),
              ),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
          ),
        ),
        Text(
          'Empleados',
          style: TextStyle(
            color: color, 
            fontSize: 24, 
            fontWeight: FontWeight.w700
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.toNamed(Routes.myCreateEmployeeView),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (_) {},
              decoration: InputDecoration(
                hintText: 'Buscar empleados...',
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

  Widget _buildEmployeesList(BuildContext context) {
    return ListView.builder(
      itemCount: _sampleEmployees.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.myEmployeePortalView),
          child: _employeeCard(context, _sampleEmployees[index]));
      },
    );
  }

  Widget _employeeCard(BuildContext context, Map<String, dynamic> employee) {
    final color = Theme.of(context).colorScheme.primary;
    
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
          // Avatar con gradiente (mismo diseño que clientes pero con icono de persona)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.5),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 24, color: Colors.teal),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employee['email'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  employee['phone'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: employee['status'] == 'Activo'
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              employee['status'],
              style: TextStyle(
                color: employee['status'] == 'Activo'
                    ? Colors.green
                    : Colors.grey,
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