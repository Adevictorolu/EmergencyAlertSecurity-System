import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dualert/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  final _db = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  void start(String uid) {
    // If listener is already active, ignore additional startup calls to prevent memory leaks.
    if (_subscription != null) return;

    _subscription = _db.collection('users').doc(uid).snapshots().listen(
      (doc) {
        if (doc.exists && doc.data() != null) {
          _user = AppUser.fromMap(doc.data()!);
          notifyListeners();
        } else {
          // Document doesn't exist; sign out to avoid infinite loading screen
          FirebaseAuth.instance.signOut();
        }
      },
      onError: (e) {
        FirebaseAuth.instance.signOut();
      },
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

