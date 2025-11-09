import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  final _db = FirebaseFirestore.instance;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _listener;

  void start(String uid) {
    _listener = _db.collection('users').doc(uid).snapshots();
    _listener!.listen((doc) {
      if (doc.exists && doc.data() != null) {
        _user = AppUser.fromMap(doc.data()!);
        notifyListeners();
      }
    });
  }

  void stop() {
    _listener = null;
    _user = null;
    notifyListeners();
  }
}
