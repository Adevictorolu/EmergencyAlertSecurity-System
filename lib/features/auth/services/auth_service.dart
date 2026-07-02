import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:dualert/models/app_user.dart';
import 'package:dualert/models/alert_model.dart';
import 'package:dualert/core/services/email_service.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges();

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network issue. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _handleGenericException(dynamic e) {
    if (e is SocketException) {
      return 'Network issue. Please check your connection.';
    }
    return e.toString().contains('Exception:') ? e.toString().replaceAll('Exception: ', '') : 'Something went wrong. Please try again.';
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(_handleGenericException(e));
    }
  }

  Future<UserCredential> signUpAsStudent({
    required String fullName,
    required String email,
    required String password,
    String? matricNo,
    String? phone,
  }) async {
    try {
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
        emailVerified: false,
      );

      await _db.collection('users').doc(uid).set(appUser.toMap());
      
      // Send Email Verification
      if (!uc.user!.emailVerified) {
        await uc.user!.sendEmailVerification();
      }

      // Send Welcome Email
      await EmailService.sendWelcomeEmail(email, fullName);

      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(_handleGenericException(e));
    }
  }

  Future<UserCredential> signUpAsAdmin({
    required String fullName,
    required String email,
    required String password,
    required String adminCode,
    required String expectedAdminCode,
  }) async {
    try {
      if (adminCode != expectedAdminCode) {
        throw Exception('Invalid admin code');
      }

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
      
      // Send Email Verification
      if (!uc.user!.emailVerified) {
        await uc.user!.sendEmailVerification();
      }

      // Send Welcome Email
      await EmailService.sendWelcomeEmail(email, fullName);

      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(_handleGenericException(e));
    }
  }

  Future<void> signOut() async => _auth.signOut();



  Future<void> createAlert({
    required String uid,
    required String title,
    required String description,
    String? voicePath,
  }) async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) throw Exception('Location services are disabled. Please enable them to send an alert.');
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Location permission is required to send an alert.');
        }
      }
      
      LocationData? locData;
      try {
        locData = await location.getLocation();
      } catch (e) {
        // Fallback or ignore if it fails to get exact location
        print("Warning: Could not get exact location: $e");
      }

      DateTime? voiceRecordedAt;

      if (voicePath != null && voicePath.isNotEmpty) {
        voiceRecordedAt = DateTime.now();
      }

      final id = const Uuid().v4();

      final alert = AlertModel(
        id: id,
        title: title,
        description: description,
        handled: false,
        createdAt: DateTime.now(),
        senderUid: uid,
        lat: locData?.latitude,
        lng: locData?.longitude,
        voiceUrl: voicePath,
        voiceRecordedAt: voiceRecordedAt,
      );

      await _db.collection('alerts').doc(id).set(alert.toMap());

      // Fetch user to send confirmation email
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['email'] != null) {
          await EmailService.broadcastEmergencyAlert(
            userData['fullName'] ?? 'User',
            title,
            description,
          );
        }
      }
    } on SocketException {
      throw Exception('Network issue. Please check your connection.');
    } catch (e) {
      throw Exception(_handleGenericException(e));
    }
  }

  Future<void> handleAlert(String alertId, String adminUid) async {
    try {
      await _db.collection('alerts').doc(alertId).update({
        'handled': true,
        'handledBy': adminUid,
      });

      // Fetch alert to get sender info for notification
      final alertDoc = await _db.collection('alerts').doc(alertId).get();
      if (alertDoc.exists) {
        final alertData = alertDoc.data();
        if (alertData != null && alertData['senderUid'] != null) {
          final userDoc = await _db.collection('users').doc(alertData['senderUid']).get();
          if (userDoc.exists) {
             final userData = userDoc.data();
             if (userData != null && userData['email'] != null) {
               await EmailService.sendAlertStatusUpdate(
                 userData['email'],
                 userData['fullName'] ?? 'User',
                 alertData['title'] ?? 'Alert',
                 'Handled/Resolved',
               );
             }
          }
        }
      }
    } catch (e) {
      throw Exception(_handleGenericException(e));
    }
  }
}
