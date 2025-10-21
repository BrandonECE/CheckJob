// lib/presentation/controllers/invoice/invoice_controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/invoice_entity.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';

class InvoiceController extends GetxController {
  final InvoiceRepository _invoiceRepository;
  final AdminController _adminController;
  StreamSubscription? _invoicesSubscription;

  InvoiceController({
    required InvoiceRepository invoiceRepository,
    required AdminController adminController,
  }) : _invoiceRepository = invoiceRepository,
       _adminController = adminController;

  final RxList<InvoiceEntity> invoices = <InvoiceEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaveButtonLoading = false.obs;
  final Rx<InvoiceEntity?> selectedInvoice = Rx<InvoiceEntity?>(null);

  @override
  void onInit() {
    _loadInvoices();
    super.onInit();
  }

  @override
  void onClose() {
    _invoicesSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadInvoices() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _invoicesSubscription = _invoiceRepository.getInvoices().listen(
      (invoicesList) {
        invoices.assignAll(invoicesList);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Error al cargar facturas: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> refreshInvoices() async {
    try {
      isLoading.value = true;
      final invoicesList = await _invoiceRepository.getInvoicesOnce();
      invoices.assignAll(invoicesList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar facturas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectInvoice(String invoiceID) async {
    try {
      isLoading.value = true;
      selectedInvoice.value = await _invoiceRepository.getInvoice(invoiceID);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Error al cargar factura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void changeLoadingValue(bool isLoadingNewValue) {
    isLoading.value = isLoadingNewValue;
  }

  void clearSelection() {
    selectedInvoice.value = null;
  }

  Future<void> createInvoice({
    required String taskID,
    required String clientName,
    required String clientID,
    required double amount,
    required String status,
    required DateTime dueDate,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      final invoice = InvoiceEntity(
        invoicesID: _generateInvoiceId(),
        taskID: taskID,
        clientName: clientName,
        clientID: clientID,
        amount: amount,
        status: status,
        dueDate: Timestamp.fromDate(dueDate),
        createdAt: Timestamp.now(),
      );

      // 1) Crear factura
      await _invoiceRepository.createInvoice(invoice);

      // 2) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'invoice_created',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: invoice.invoicesID,
        );
      } catch (auditError) {
        // 3) Si falla el audit, revertir (borrar factura creada)
        try {
          await _invoiceRepository.deleteInvoice(invoice.invoicesID);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la creación.\n'
                'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se revirtió la creación.',
        );
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Factura creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshInvoices();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la factura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateInvoice(InvoiceEntity invoice) async {
    try {
      isLoading.value = true;
      isSaveButtonLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Guardar el estado anterior para posible rollback
      final invoiceIndex = invoices.indexWhere(
        (i) => i.invoicesID == invoice.invoicesID,
      );
      if (invoiceIndex == -1) throw Exception('Factura no encontrada');

      final oldInvoice = invoices[invoiceIndex];

      // 2) Actualizar
      await _invoiceRepository.updateInvoice(invoice);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'invoice_managed',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: invoice.invoicesID,
        );
      } catch (auditError) {
        // 4) Si falla audit, revertir a oldInvoice
        try {
          await _invoiceRepository.updateInvoice(oldInvoice);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la actualización.\n'
                'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se revirtió la actualización.',
        );
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Factura actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshInvoices();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la factura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
        isSaveButtonLoading.value = false;
      isLoading.value = false;
    }
  }

  Future<void> deleteInvoice(String invoiceID, String invoiceReference) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Obtener snapshot actual de la factura para poder restaurarlo si hace falta
      final invoiceIndex = invoices.indexWhere(
        (i) => i.invoicesID == invoiceID,
      );
      if (invoiceIndex == -1) throw Exception('Factura no encontrada');

      final existingInvoice = invoices[invoiceIndex];

      // 2) Borrar
      await _invoiceRepository.deleteInvoice(invoiceID);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'invoice_deleted',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: invoiceReference,
        );
      } catch (auditError) {
        // 4) Si falla audit, intentar restaurar el documento eliminado
        try {
          await _invoiceRepository.createInvoice(existingInvoice);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni restaurar la factura.\n'
                'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception(
            'Audit y rollback fallaron: $auditError / $rollbackError',
          );
        }
        throw Exception(
          'No se pudo registrar la acción (audit). Se restauró la factura eliminada.',
        );
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Factura eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshInvoices();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la factura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos para obtener estadísticas
  Map<String, double> getInvoiceStats() {
    double total = 0;
    double paid = 0;
    double pending = 0;

    for (final invoice in invoices) {
      total += invoice.amount;
      if (invoice.status == 'paid') {
        paid += invoice.amount;
      } else if (invoice.status == 'pending') {
        pending += invoice.amount;
      }
    }

    return {'total': total, 'paid': paid, 'pending': pending};
  }

  String _generateInvoiceId() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}';
  }
}