// lib/data/services/invoice_service_impl.dart
import 'package:check_job/domain/entities/invoice_entity.dart';
import 'package:check_job/domain/services/invoice_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceServiceImpl implements InvoiceService {
  final FirebaseFirestore _firestore;

  InvoiceServiceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<InvoiceEntity>> getInvoices() {
    try {
      return _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener facturas: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => InvoiceEntity.fromFirestore(doc.data()))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error al crear stream de facturas: $e');
    }
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesOnce() async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((doc) => InvoiceEntity.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      return Future.error('Error al obtener facturas: $e');
    }
  }

  @override
  Future<void> createInvoice(InvoiceEntity invoice) async {
    try {
      await _firestore
          .collection('invoices')
          .doc(invoice.invoicesID)
          .set(invoice.toMap());
    } catch (e) {
      return Future.error('Error al crear factura: $e');
    }
  }

  @override
  Future<void> updateInvoice(InvoiceEntity invoice) async {
    try {
      await _firestore
          .collection('invoices')
          .doc(invoice.invoicesID)
          .update(invoice.toMap());
    } catch (e) {
      return Future.error('Error al actualizar factura: $e');
    }
  }

  @override
  Future<void> deleteInvoice(String invoiceID) async {
    try {
      await _firestore.collection('invoices').doc(invoiceID).delete();
    } catch (e) {
      return Future.error('Error al eliminar factura: $e');
    }
  }

  @override
  Future<InvoiceEntity> getInvoice(String invoiceID) async {
    try {
      final doc = await _firestore.collection('invoices').doc(invoiceID).get(GetOptions(source: Source.server));
      if (!doc.exists) {
        throw Exception('Factura no encontrada');
      }
      return InvoiceEntity.fromFirestore(doc.data()!);
    } catch (e) {
      return Future.error('Error al obtener factura: $e');
    }
  }
}