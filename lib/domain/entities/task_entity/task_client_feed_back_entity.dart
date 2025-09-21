import 'package:cloud_firestore/cloud_firestore.dart';

class TaskClientFeedbackEntity {
  final bool? approved;
  final Timestamp submittedAt;

  TaskClientFeedbackEntity({this.approved, required this.submittedAt});

  Map<String, dynamic> toMap() {
    return {'approved': approved, 'submittedAt': submittedAt};
  }

  factory TaskClientFeedbackEntity.fromMap(Map<String, dynamic> map) {
    return TaskClientFeedbackEntity(
      approved: map['approved'],
      submittedAt: map['submittedAt'],
    );
  }
}
