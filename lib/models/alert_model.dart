import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final bool handled;
  final DateTime createdAt;
  final String senderUid; // ✅ Correct field
  final double? lat;
  final double? lng;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.handled,
    required this.createdAt,
    required this.senderUid,
    this.lat,
    this.lng,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      senderUid: map['senderUid'] ?? '',
      handled: map['handled'] ?? false,
      lat: map['lat'] != null ? (map['lat'] as num).toDouble() : null,
      lng: map['lng'] != null ? (map['lng'] as num).toDouble() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'senderUid': senderUid,
      'handled': handled,
      'lat': lat,
      'lng': lng,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
