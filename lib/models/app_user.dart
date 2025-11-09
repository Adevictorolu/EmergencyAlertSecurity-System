class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String role;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role, String? matricNo, String? phone,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }
}
