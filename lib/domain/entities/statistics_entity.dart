// lib/domain/entities/statistic_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticEntity {
  final String statisticID;
  final String metric;
  final double value;
  final DateTime date;
  final Map<String, dynamic>? metadata;

  StatisticEntity({
    required this.statisticID,
    required this.metric,
    required this.value,
    required this.date,
    this.metadata,
  });

  factory StatisticEntity.fromFirestore(Map<String, dynamic> data, String id) {
    return StatisticEntity(
      statisticID: id,
      metric: (data['metric'] ?? '') as String,
      value: ((data['value'] ?? 0) is num) ? (data['value'] as num).toDouble() : double.tryParse(data['value']?.toString() ?? '0') ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      metadata: data['metadata'] is Map ? Map<String, dynamic>.from(data['metadata']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'metric': metric,
      'value': value,
      'date': Timestamp.fromDate(date),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
