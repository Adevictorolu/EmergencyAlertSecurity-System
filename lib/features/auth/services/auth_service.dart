import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'package:dualert/models/app_user.dart';
import 'package:dualert/models/alert_model.dart';
import 'package:dualert/core/services/email_service.dart';

// Only import dart:io on non-web platforms
import 'auth_service_io.dart' if (dart.library.html) 'auth_service_web.dart';

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
    final eStr = e.toString();
    if (isSocketException(e)) {
      return 'Network issue. Please check your connection.';
    }
    return eStr.contains('Exception:')
        ? eStr.replaceAll('Exception: ', '')
        : 'Something went wrong. Please try again.';
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
      double? lat;
      double? lng;

      if (kIsWeb) {
        // Use browser Geolocation API on web
        final position = await getWebLocation();
        lat = position?['lat'];
        lng = position?['lng'];
      } else {
        // Use location package on native platforms
        final locData = await getNativeLocation();
        lat = locData?['lat'];
        lng = locData?['lng'];
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
        lat: lat,
        lng: lng,
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
          final userDoc =
              await _db.collection('users').doc(alertData['senderUid']).get();
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
