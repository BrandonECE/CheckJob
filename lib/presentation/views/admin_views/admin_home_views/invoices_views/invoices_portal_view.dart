import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyInvoicePortalView extends StatelessWidget {
  const MyInvoicePortalView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = false; // Cambiar a true para probar estado pagada
    final bool isOverdue = true; // Cambiar según la fecha
    
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
              _buildInvoiceInfo(context),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildEditForm(context, isPaid, isOverdue),
                ),
              ),
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
          'Det. Factura',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }

  Widget _buildInvoiceInfo(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Container(
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
            backgroundColor: color.withOpacity(0.1),
            child: Icon(Icons.receipt, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAC-001', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('Empresa ABC', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('15 Nov 2023', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, bool isPaid, bool isOverdue) {
    final status = isPaid ? 'Pagada' : (isOverdue ? 'Vencida' : 'Pendiente');
    
    return Container(
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
      child: Column(
        children: [
          _buildAmountField(isPaid),
          const SizedBox(height: 16),
          _buildDateField(isPaid),
          const SizedBox(height: 16),
          _buildStatusDropdown(status, isPaid),
          const SizedBox(height: 20),
          if (!isPaid) _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountField(bool isPaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isPaid ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '\$1,200.00'),
                  readOnly: isPaid,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: isPaid ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(bool isPaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isPaid ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: '2023-11-15'),
                  readOnly: isPaid,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: isPaid ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
              ),
              if (!isPaid)
                IconButton(
                  icon: Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade600),
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(String currentStatus, bool isPaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isPaid ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentStatus,
              isExpanded: true,
              items: ['Pendiente', 'Pagada', 'Vencida'].map((String status) {
                Color statusColor = Colors.green;
                if (status == 'Pendiente') statusColor = Colors.orange;
                if (status == 'Vencida') statusColor = Colors.red;
                
                return DropdownMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 18,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(status),
                    ],
                  ),
                );
              }).toList(),
              onChanged: isPaid ? null : (String? newValue) {},
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pagada':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.pending;
      case 'Vencida':
        return Icons.error;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.snackbar(
            'Guardado',
            'Los cambios se han guardado correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, color: Colors.white, size: 20),
        label: const Text(
          'Guardar Cambios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}