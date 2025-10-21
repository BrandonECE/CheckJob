// lib/domain/entities/invoice_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InvoiceEntity {
  final String invoicesID;
  final String taskID;
  final String clientName;
  final String clientID;
  final double amount;
  final String status; // 'paid', 'pending', 'overdue'
  final Timestamp dueDate;
  final Timestamp createdAt;

  InvoiceEntity({
    required this.invoicesID,
    required this.taskID,
    required this.clientName,
    required this.clientID,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  factory InvoiceEntity.fromFirestore(Map<String, dynamic> data) {
    return InvoiceEntity(
      invoicesID: data['invoicesID'] ?? '',
      taskID: data['taskID'] ?? '',
      clientName: data['clientName'] ?? '',
      clientID: data['clientID'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] ?? 'pending',
      dueDate: data['dueDate'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoicesID': invoicesID,
      'taskID': taskID,
      'clientName': clientName,
      'clientID': clientID,
      'amount': amount,
      'status': status,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }

  InvoiceEntity copyWith({
    String? invoicesID,
    String? taskID,
    String? clientName,
    String? clientID,
    double? amount,
    String? status,
    Timestamp? dueDate,
    Timestamp? createdAt,
  }) {
    return InvoiceEntity(
      invoicesID: invoicesID ?? this.invoicesID,
      taskID: taskID ?? this.taskID,
      clientName: clientName ?? this.clientName,
      clientID: clientID ?? this.clientID,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper para obtener el color según el estado
  Color get statusColor {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  // Helper para obtener el texto del estado
  String get statusText {
    switch (status) {
      case 'paid':
        return 'Pagada';
      case 'overdue':
        return 'Vencida';
      case 'pending':
      default:
        return 'Pendiente';
    }
  }

  // Helper para obtener el icono según el estado
  IconData get statusIcon {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.error;
      case 'pending':
      default:
        return Icons.pending;
    }
  }
}