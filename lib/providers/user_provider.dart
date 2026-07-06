import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dualert/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  final _db = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  void start(String uid) {
    // If listener is already active, ignore additional startup calls to prevent memory leaks.
    if (_subscription != null) return;

    _isLoading = true;
    _user = null;
    notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = AppUser(
        uid: currentUser.uid,
        fullName: currentUser.displayName ??
            (currentUser.email?.split('@').first ?? 'User'),
        email: currentUser.email ?? '',
        role: 'student',
        emailVerified: currentUser.emailVerified,
      );
    }

    _subscription = _db.collection('users').doc(uid).snapshots().listen(
      (doc) {
        if (doc.exists && doc.data() != null) {
          _user = AppUser.fromMap(doc.data()!);
          _isLoading = false;
          notifyListeners();
        } else {
          // Keep the user signed in and show a loading/placeholder state if the profile
          // document has not appeared yet or is temporarily unavailable.
          if (_user == null) {
            final fallbackUser = FirebaseAuth.instance.currentUser;
            if (fallbackUser != null) {
              _user = AppUser(
                uid: fallbackUser.uid,
                fullName: fallbackUser.displayName ??
                    (fallbackUser.email?.split('@').first ?? 'User'),
                email: fallbackUser.email ?? '',
                role: 'student',
                emailVerified: fallbackUser.emailVerified,
              );
            }
          }
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _isLoading = false;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

