import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyReportsView extends StatelessWidget {
  const MyReportsView({super.key});

  final List<Map<String, dynamic>> reports = const [
    {'title': 'Reporte de Tareas Mensual', 'type': 'PDF', 'date': 'Nov 2023', 'size': '2.4 MB'},
    {'title': 'Estadísticas de Empleados', 'type': 'Excel', 'date': 'Oct 2023', 'size': '1.8 MB'},
    {'title': 'Facturación Trimestral', 'type': 'PDF', 'date': 'Q3 2023', 'size': '3.2 MB'},
    {'title': 'Inventario Actual', 'type': 'Excel', 'date': 'Nov 2023', 'size': '1.5 MB'},
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
              _buildReportTypes(context),
              const SizedBox(height: 20),
              _buildReportsList(context),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Text(
          'Gen. Reportes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildReportTypes(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _reportTypeButton(context, 'Tareas', Icons.task),
        _reportTypeButton(context, 'Facturación', Icons.receipt),
        _reportTypeButton(context, 'Clientes', Icons.people),
        _reportTypeButton(context, 'Inventario', Icons.inventory),
        _reportTypeButton(context, 'Empleados', Icons.engineering),
      ],
    );
  }

  Widget _reportTypeButton(BuildContext context, String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildReportsList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _reportCard(context, reports[index]);
        },
      ),
    );
  }

  Widget _reportCard(BuildContext context, Map<String, dynamic> report) {
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
            backgroundColor: report['type'] == 'PDF' 
                ? Colors.red.shade100 
                : Colors.green.shade100,
            child: Icon(
              report['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
              color: report['type'] == 'PDF' ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['title'], style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Fecha: ${report['date']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Tamaño: ${report['size']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
            onPressed: () {},
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