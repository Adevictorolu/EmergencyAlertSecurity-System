import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final bool handled;
  final DateTime createdAt;
  final String senderUid;
  final String? handledBy;
  final double? lat;
  final double? lng;
  final String? voiceUrl;
  final DateTime? voiceRecordedAt;
  final String? address;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    this.handled = false,
    required this.createdAt,
    required this.senderUid,
    this.handledBy,
    this.lat,
    this.lng,
    this.voiceUrl,
    this.voiceRecordedAt,
    this.address,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    // Robust parsing for Timestamp to prevent TypeError crashes
    DateTime parsedCreatedAt = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      }
    }

    DateTime? voiceRecordedAt;
    if (map['voiceRecordedAt'] != null) {
      if (map['voiceRecordedAt'] is Timestamp) {
        voiceRecordedAt = (map['voiceRecordedAt'] as Timestamp).toDate();
      } else if (map['voiceRecordedAt'] is String) {
        voiceRecordedAt = DateTime.tryParse(map['voiceRecordedAt']);
      }
    }

    return AlertModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      senderUid: map['senderUid']?.toString() ?? '',
      handled: map['handled'] ?? false,
      handledBy: map['handledBy']?.toString(),
      lat: map['lat'] != null ? (map['lat'] as num).toDouble() : null,
      lng: map['lng'] != null ? (map['lng'] as num).toDouble() : null,
      createdAt: parsedCreatedAt,
      voiceUrl: map['voiceUrl']?.toString(),
      voiceRecordedAt: voiceRecordedAt,
      address: map['address']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'senderUid': senderUid,
      'handled': handled,
      'handledBy': handledBy,
      'lat': lat,
      'lng': lng,
      'createdAt': Timestamp.fromDate(createdAt),
      'voiceUrl': voiceUrl,
      'voiceRecordedAt': voiceRecordedAt != null ? Timestamp.fromDate(voiceRecordedAt!) : null,
      'address': address,
    };
  }

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? handled,
    DateTime? createdAt,
    String? senderUid,
    String? handledBy,
    double? lat,
    double? lng,
    String? voiceUrl,
    DateTime? voiceRecordedAt,
    String? address,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      handled: handled ?? this.handled,
      createdAt: createdAt ?? this.createdAt,
      senderUid: senderUid ?? this.senderUid,
      handledBy: handledBy ?? this.handledBy,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceRecordedAt: voiceRecordedAt ?? this.voiceRecordedAt,
      address: address ?? this.address,
    );
  }
}
