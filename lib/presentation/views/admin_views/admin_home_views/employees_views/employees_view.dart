import 'package:check_job/config/routes.dart';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/presentation/controllers/employee/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyEmployeesView extends StatelessWidget {
  MyEmployeesView({super.key});

  final EmployeeController controller = Get.find<EmployeeController>();

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
              _buildEmployeesList(context),
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final employees = controller.employees;

      if (employees.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text(
              'No hay empleados registrados',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                await controller.selectEmployee(employees[index].employeesID);
                Get.toNamed(Routes.myEmployeePortalView);
              },
              child: _employeeCard(context, employees[index]),
            );
          },
        ),
      );
    });
  }

  Widget _employeeCard(BuildContext context, EmployeeEntity employee) {
    final isActive = employee.isActive;
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
          // Avatar con foto o icono por defecto
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
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: employee.photoData != null
                  ? MemoryImage(employee.photoData!)
                  : null,
              child: employee.photoData == null
                  ? Icon(Icons.person, size: 24, color: Colors.teal)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    employee.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600,overflow: TextOverflow.ellipsis),
                  ),
                ),
                Text(
                  employee.phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),]
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive == null  ?Colors.grey.shade200 : isActive ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive == null ? 'Inactivo' : isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: isActive == null ? Colors.grey : isActive ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]
      
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}