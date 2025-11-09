import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/alert_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ SIGN IN
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ✅ SIGN UP AS STUDENT
  Future<UserCredential> signUpAsStudent({
    required String fullName,
    required String email,
    required String password,
    String? matricNo,
    String? phone,
  }) async {
    final uc = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = uc.user!.uid;

    final appUser = AppUser(
      uid: uid,
      fullName: fullName,
      email: email,
      role: 'student',
      matricNo: matricNo,
      phone: phone,
    );

    await _db.collection('users').doc(uid).set(appUser.toMap());
    return uc;
  }

  // ✅ SIGN UP AS ADMIN
  Future<UserCredential> signUpAsAdmin({
    required String fullName,
    required String email,
    required String password,
    required String adminCode,
    required String expectedAdminCode,
  }) async {
    if (adminCode != expectedAdminCode) throw Exception('Invalid admin code');

    final uc = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = uc.user!.uid;

    final appUser = AppUser(
      uid: uid,
      fullName: fullName,
      email: email,
      role: 'admin',
    );

    await _db.collection('users').doc(uid).set(appUser.toMap());
    return uc;
  }

  // ✅ SIGN OUT
  Future<void> signOut() async => _auth.signOut();

  // ✅ CREATE ALERT
  Future<void> createAlert({
    required String uid,
    required String title,
    required String description,
  }) async {
    final id = const Uuid().v4();

    // final alert = AlertModel(
    //   id: id,
    //   title: title,
    //   description: description,
    //   handled: false, // ✅ FIXED
    //   createdAt: DateTime.now(),
    //   senderUid: uid,
    // );
    final alert = AlertModel(
      id: id,
      title: title,
      description: description,
      handled: false,
      createdAt: DateTime.now(),
      senderUid: uid, // ✅ important
    );

    await _db.collection('alerts').doc(id).set(alert.toMap());
  }

  // ✅ HANDLE ALERT
  Future<void> handleAlert(String alertId, String adminUid) async {
    await _db.collection('alerts').doc(alertId).update({
      'handled': true,
      'handledBy': adminUid,
    });
  }
}
