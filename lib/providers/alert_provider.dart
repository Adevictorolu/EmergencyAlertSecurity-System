import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  List<Map<String, dynamic>> _alerts = [];
  bool _loading = false;

  List<Map<String, dynamic>> get alerts => _alerts;
  bool get loading => _loading;

  void start() {
    if (_sub != null) return;
    _loading = true;
    notifyListeners();
    _sub = _db.collection('alerts').orderBy('createdAt', descending: true).snapshots().listen((snap) {
      _alerts = snap.docs.map((d) {
        final m = d.data();
        return {
          'docId': d.id,
          'id': m['id'],
          'uid': m['uid'],
          'title': m['title'],
          'description': m['description'],
          'createdAt': m['createdAt'] ?? '',
          'handled': m['handled'] ?? false,
          'handledBy': m['handledBy'],
        };
      }).toList();
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      _loading = false;
      notifyListeners();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _alerts = [];
    notifyListeners();
  }
}
