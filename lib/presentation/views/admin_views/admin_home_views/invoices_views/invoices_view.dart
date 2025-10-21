import 'package:check_job/config/routes.dart';
import 'package:check_job/presentation/controllers/invoice/invoice_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/entities/enities.dart';

class MyInvoicesView extends StatelessWidget {
  MyInvoicesView({super.key});

  final InvoiceController controller = Get.find<InvoiceController>();

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
    return Obx(() {
      final stats = controller.getInvoiceStats();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(context, 'Total', '\$${stats['total']!.toStringAsFixed(2)}', Icons.attach_money),
          _statItem(context, 'Pagadas', '\$${stats['paid']!.toStringAsFixed(2)}', Icons.check_circle),
          _statItem(context, 'Pendientes', '\$${stats['pending']!.toStringAsFixed(2)}', Icons.pending),
        ],
      );
    });
  }

  Widget _statItem(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: Text(
            key: ValueKey(value),
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInvoicesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final invoices = controller.invoices;

      if (invoices.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text(
              'No hay facturas registradas',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                await controller.selectInvoice(invoices[index].invoicesID);
                Get.toNamed(Routes.myInvoicePortalView);
              },
              child: _invoiceCard(context, invoices[index]),
            );
          },
        ),
      );
    });
  }

  Widget _invoiceCard(BuildContext context, InvoiceEntity invoice) {
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
                Text(invoice.invoicesID, style: TextStyle(fontWeight: FontWeight.w600)),
                Text("${invoice.taskID} - ${invoice.clientName}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(_formatDate(invoice.dueDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('\$${invoice.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: Container(
              key: ValueKey('${invoice.invoicesID}_${invoice.status}'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: invoice.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                invoice.statusText,
                style: TextStyle(
                  color: invoice.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}