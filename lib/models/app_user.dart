class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String? matricNo;
  final String? phone;
  final String role; 

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.matricNo,
    this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'matricNo': matricNo,
      'phone': phone,
      'role': role, 
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      matricNo: map['matricNo'],
      phone: map['phone'],
      role: map['role'] ?? 'student',
    );
  }
}
