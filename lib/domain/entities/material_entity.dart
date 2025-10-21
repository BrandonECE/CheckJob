// lib/domain/entities/material_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaterialEntity {
  final String materialID;
  final String name;
  final int currentStock;
  final int minStock;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialEntity({
    required this.materialID,
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialEntity.fromFirestore(Map<String, dynamic> data) {
    return MaterialEntity(
      materialID: data['materialID'] ?? '',
      name: data['name'] ?? '',
      currentStock: data['currentStock'] ?? 0,
      minStock: data['minStock'] ?? 0,
      unit: data['unit'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialID': materialID,
      'name': name,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MaterialEntity copyWith({
    String? materialID,
    String? name,
    int? currentStock,
    int? minStock,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialEntity(
      materialID: materialID ?? this.materialID,
      name: name ?? this.name,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get status {
    if (currentStock <= 0) return 'Agotado';
    if (currentStock <= minStock * 0.3) return 'Crítico';
    if (currentStock <= minStock) return 'Bajo';
    return 'Normal';
  }

  Color get statusColor {
    switch (status) {
      case 'Agotado':
        return Colors.red;
      case 'Crítico':
        return Colors.deepOrange;
      case 'Bajo':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}