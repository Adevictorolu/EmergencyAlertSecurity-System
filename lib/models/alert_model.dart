import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final bool handled;
  final DateTime createdAt;
  final String senderUid; // ✅ Correct field

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.handled,
    required this.createdAt,
    required this.senderUid,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map) {
  return AlertModel(
    id: map['id'] ?? '',
    title: map['title'] ?? 'No Title',
    description: map['description'] ?? 'No Description',
    handled: map['handled'] ?? false,
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    senderUid: map['senderUid'] ?? '',
  );
}
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'handled': handled,
      'createdAt': createdAt,
      'senderUid': senderUid, // ✅ Must be saved
    };
  }
}
