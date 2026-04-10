import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/alert_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
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
  Future<void> signOut() async => _auth.signOut();
  Future<void> createAlert({
    required String uid,
    required String title,
    required String description,
  }) async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) throw Exception('Location Service Disabled');
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location Permission Denied');
      }
    }
    final locData = await location.getLocation();

    final id = const Uuid().v4();

    final alert = AlertModel(
      id: id,
      title: title,
      description: description,
      handled: false,
      createdAt: DateTime.now(),
      senderUid: uid,
      lat: locData.latitude,
      lng: locData.longitude,
    );

    await _db.collection('alerts').doc(id).set(alert.toMap());
  }
  Future<void> handleAlert(String alertId, String adminUid) async {
    await _db.collection('alerts').doc(alertId).update({
      'handled': true,
      'handledBy': adminUid,
    });
  }
}
