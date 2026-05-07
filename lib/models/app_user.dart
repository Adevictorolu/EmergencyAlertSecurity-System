class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String? matricNo;
  final String? phone;
  final String role;
  final String? voiceUrl;
  final bool emailVerified;
  final DateTime? voiceRecordedAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.matricNo,
    this.phone,
    required this.role,
    this.voiceUrl,
    this.emailVerified = false,
    this.voiceRecordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'matricNo': matricNo,
      'phone': phone,
      'role': role,
      'voiceUrl': voiceUrl,
      'emailVerified': emailVerified,
      'voiceRecordedAt': voiceRecordedAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? 'Unknown',
      email: map['email']?.toString() ?? '',
      matricNo: map['matricNo']?.toString(),
      phone: map['phone']?.toString(),
      role: map['role']?.toString() ?? 'student',
      voiceUrl: map['voiceUrl']?.toString(),
      emailVerified: map['emailVerified'] ?? false,
      voiceRecordedAt: map['voiceRecordedAt'] != null
          ? DateTime.tryParse(map['voiceRecordedAt'].toString())
          : null,
    );
  }
}
