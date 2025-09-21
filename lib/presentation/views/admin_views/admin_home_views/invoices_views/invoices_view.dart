import 'package:check_job/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyInvoicesView extends StatelessWidget {
  const MyInvoicesView({super.key});

  final List<Map<String, dynamic>> invoices = const [
    {'id': 'FAC-001', 'client': 'Empresa ABC', 'amount': '\$1,200.00', 'status': 'Pagada', 'date': '15 Nov 2023'},
    {'id': 'FAC-002', 'client': 'Compañía XYZ', 'amount': '\$850.50', 'status': 'Pendiente', 'date': '18 Nov 2023'},
    {'id': 'FAC-003', 'client': 'Negocio 123', 'amount': '\$2,340.75', 'status': 'Vencida', 'date': '10 Nov 2023'},
    {'id': 'FAC-004', 'client': 'Cliente Nuevo', 'amount': '\$450.00', 'status': 'Pagada', 'date': '20 Nov 2023'},
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
              _buildInvoiceStats(context),
              const SizedBox(height: 20),
              _buildInvoicesList(context),
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
          'Facturas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildInvoiceStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(context, 'Total', '\$4,841.25', Icons.attach_money),
        _statItem(context, 'Pagadas', '\$1,650.00', Icons.check_circle),
        _statItem(context, 'Pendientes', '\$850.50', Icons.pending),
      ],
    );
  }

  Widget _statItem(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInvoicesList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Get.toNamed(Routes.myInvoicePortalView),
            child: _invoiceCard(context, invoices[index]));
        },
      ),
    );
  }

  Widget _invoiceCard(BuildContext context, Map<String, dynamic> invoice) {
    Color statusColor = Colors.green;
    if (invoice['status'] == 'Pendiente') statusColor = Colors.orange;
    if (invoice['status'] == 'Vencida') statusColor = Colors.red;

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
            child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice['id'], style: TextStyle(fontWeight: FontWeight.w600)),
                Text(invoice['client'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(invoice['date'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(invoice['amount'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              invoice['status'],
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
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