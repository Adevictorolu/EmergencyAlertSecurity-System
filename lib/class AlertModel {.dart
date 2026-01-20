class AlertModel {
  final String id;
  final String title;
  final String description;
  final String senderUid;
  final bool handled;
  final double? lat;
  final double? lng;
``````dart
  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.senderUid,
    required this.handled,
    this.lat,
    this.lng,
  });
``````dart
  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      senderUid: map['senderUid'] ?? '',
      handled: map['handled'] ?? false,
      lat: map['lat'],
      lng: map['lng'],
    );
  }