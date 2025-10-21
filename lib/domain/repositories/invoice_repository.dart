// lib/domain/repositories/invoice_repository.dart
import 'package:check_job/domain/entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Stream<List<InvoiceEntity>> getInvoices();
  Future<List<InvoiceEntity>> getInvoicesOnce();
  Future<void> createInvoice(InvoiceEntity invoice);
  Future<void> updateInvoice(InvoiceEntity invoice);
  Future<void> deleteInvoice(String invoiceID);
  Future<InvoiceEntity> getInvoice(String invoiceID);
}