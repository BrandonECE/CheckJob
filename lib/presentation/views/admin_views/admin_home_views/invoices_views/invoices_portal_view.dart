import 'package:check_job/presentation/controllers/invoice/invoice_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/entities/enities.dart';

class MyInvoicePortalView extends StatefulWidget {
  MyInvoicePortalView({super.key});

  @override
  State<MyInvoicePortalView> createState() => _MyInvoicePortalViewState();
}

class _MyInvoicePortalViewState extends State<MyInvoicePortalView> {
  final InvoiceController controller = Get.find<InvoiceController>();
  late TextEditingController _amountController;
  late String _tempStatus;
  DateTime? _tempDueDate;

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales de la factura
    final invoice = controller.selectedInvoice.value;
    if (invoice != null) {
      _amountController = TextEditingController(text: invoice.amount.toStringAsFixed(2));
      _tempStatus = invoice.status;
      _tempDueDate = invoice.dueDate.toDate();
    } else {
      _amountController = TextEditingController();
      _tempStatus = 'pending';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.changeLoadingValue(false);
      },
      child: Scaffold(
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
                    child: _buildEditForm(context),
                  ),
                ),
              ],
            ),
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
    return Obx(() {
      final invoice = controller.selectedInvoice.value;
      if (invoice == null) {
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
          child: Center(
            child: Text(
              'Factura no encontrada',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ),
        );
      }

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
                  Text(invoice.invoicesID, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(invoice.clientName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text(_formatDate(_tempDueDate ?? invoice.dueDate.toDate()), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEditForm(BuildContext context) {
    return Obx(() {
      final invoice = controller.selectedInvoice.value;
      if (invoice == null) {
        return const Center(child: Text('No hay datos de la factura'));
      }

      final isPaid = invoice.status == 'paid';
      
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
            _buildAmountField(invoice, isPaid),
            const SizedBox(height: 16),
            _buildDateField(invoice, isPaid),
            const SizedBox(height: 16),
            _buildStatusDropdown(invoice, isPaid),
            const SizedBox(height: 20),
            if (!isPaid) _buildSaveButton(context, invoice),
          ],
        ),
      );
    });
  }

  Widget _buildAmountField(InvoiceEntity invoice, bool isPaid) {
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
                  controller: _amountController,
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

  Widget _buildDateField(InvoiceEntity invoice, bool isPaid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de vencimiento',
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
                  controller: TextEditingController(
                    text: _formatDate(_tempDueDate ?? invoice.dueDate.toDate())
                  ),
                  readOnly: true,
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
                  onPressed: () => _selectDate(context, invoice),
                ),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildStatusDropdown(InvoiceEntity invoice, bool isPaid) {
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
          child: Builder(builder: (context) {
            // determinar si la fecha de vencimiento ya pasó (comparando solo la fecha)
            final dueDate = invoice.dueDate.toDate();
            final today = DateTime.now();
            final todayOnly = DateTime(today.year, today.month, today.day);
            final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
            final dueHasPassed = dueOnly.isBefore(todayOnly);

            // decidir los estados disponibles
            final List<String> availableStatuses;
            if (invoice.status == 'paid') {
              availableStatuses = ['paid'];
            } else if (invoice.status == 'overdue' || dueHasPassed) {
              // si ya está marcado como overdue o la fecha ya pasó, mostramos las 3 opciones
              availableStatuses = ['pending', 'paid', 'overdue'];
            } else {
              // caso normal: pendiente y pagada
              availableStatuses = ['pending', 'paid'];
            }

            // Asegurarnos que _tempStatus sea un valor válido (por si algo raro pasó)
            if (!availableStatuses.contains(_tempStatus)) {
              // si la _tempStatus actual no está disponible, ajustamos a la primera opción válida
              _tempStatus = availableStatuses.first;
            }

            return DropdownButton<String>(
              value: _tempStatus,
              isExpanded: true,
              items: availableStatuses.map((String status) {
                Color statusColor;
                String statusText;
                switch (status) {
                  case 'paid':
                    statusColor = Colors.green;
                    statusText = 'Pagada';
                    break;
                  case 'pending':
                    statusColor = Colors.orange;
                    statusText = 'Pendiente';
                    break;
                  case 'overdue':
                    statusColor = Colors.red;
                    statusText = 'Vencida';
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusText = status;
                }

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
                      Text(statusText),
                    ],
                  ),
                );
              }).toList(),
              onChanged: isPaid
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _tempStatus = newValue;
                        });
                      }
                    },
            );
          }),
        ),
      ),
    ],
  );
}
    Widget _buildSaveButton(BuildContext context, InvoiceEntity invoice) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Obx(() {
      if (controller.isSaveButtonLoading.value) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          label: const Text(
            'Guardar Cambios',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          onPressed: () =>  _saveChanges(invoice),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.save, color: Colors.white, size: 20),
        ),
      );
    });
  }


Future<void> _selectDate(BuildContext context, InvoiceEntity invoice) async {
  // fecha inicial (temporal)
  DateTime tempPicked = _tempDueDate ?? invoice.dueDate.toDate();

  final DateTime? picked = await showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final colorScheme = Theme.of(context).colorScheme;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // espacio para centrar título visualmente
                  Text(
                    'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  // botón cerrar pequeño a la derecha
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // --- Calendar (fija altura para que el dialog tenga tamaño controlado)
              SizedBox(
                height: 330, // ajusta esto si quieres un calendario más grande/pequeño
                child: CalendarDatePicker(
                  initialDate: tempPicked,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (d) => tempPicked = d,
                ),
              ),

              const SizedBox(height: 18),

              // --- Botones: Cancel y Confirm (estilizados y con padding)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colorScheme.primary.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        foregroundColor: colorScheme.primary,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(null),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(tempPicked),
                      child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),

              // --- Espacio extra debajo de los botones para separarlos del borde inferior
              const SizedBox(height: 18), // <- sube/ baja los botones ajustando este valor
            ],
          ),
        ),
      );
    },
  );

  // Mismo manejo que tenías: actualizar state si el usuario escogió una fecha
  if (picked != null && picked != _tempDueDate) {
    setState(() {
      _tempDueDate = picked;
    });
  }
}



  void _saveChanges(InvoiceEntity invoice) {
    final newAmount = double.tryParse(_amountController.text);
    if (newAmount == null) {
      Get.snackbar(
        'Error',
        'El monto no es válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final updatedInvoice = invoice.copyWith(
      amount: newAmount,
      dueDate: Timestamp.fromDate(_tempDueDate ?? invoice.dueDate.toDate()),
      status: _tempStatus,
    );

    controller.updateInvoice(updatedInvoice);
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'overdue':
        return Icons.error;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}