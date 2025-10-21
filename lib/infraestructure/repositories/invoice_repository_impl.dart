// lib/data/repositories/invoice_repository_impl.dart
import 'package:check_job/domain/entities/invoice_entity.dart';
import 'package:check_job/domain/repositories/invoice_repository.dart';
import 'package:check_job/domain/services/invoice_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceService _invoiceService;

  InvoiceRepositoryImpl({required InvoiceService invoiceService})
      : _invoiceService = invoiceService;

  @override
  Stream<List<InvoiceEntity>> getInvoices() {
    try {
      return _invoiceService.getInvoices();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener facturas: $e');
    }
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesOnce() async {
    try {
      return await _invoiceService.getInvoicesOnce();
    } catch (e) {
      return Future.error('Error en repositorio al obtener facturas: $e');
    }
  }

  @override
  Future<void> createInvoice(InvoiceEntity invoice) async {
    try {
      return await _invoiceService.createInvoice(invoice);
    } catch (e) {
      return Future.error('Error en repositorio al crear factura: $e');
    }
  }

  @override
  Future<void> updateInvoice(InvoiceEntity invoice) async {
    try {
      return await _invoiceService.updateInvoice(invoice);
    } catch (e) {
      return Future.error('Error en repositorio al actualizar factura: $e');
    }
  }

  @override
  Future<void> deleteInvoice(String invoiceID) async {
    try {
      return await _invoiceService.deleteInvoice(invoiceID);
    } catch (e) {
      return Future.error('Error en repositorio al eliminar factura: $e');
    }
  }

  @override
  Future<InvoiceEntity> getInvoice(String invoiceID) async {
    try {
      return await _invoiceService.getInvoice(invoiceID);
    } catch (e) {
      return Future.error('Error en repositorio al obtener factura: $e');
    }
  }
}