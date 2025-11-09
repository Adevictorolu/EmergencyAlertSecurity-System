import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/alert_model.dart';

class ViewAlertPage extends StatelessWidget {
  const ViewAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Alerts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('uid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No alerts submitted', style: TextStyle(color: Colors.white)));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final alert = AlertModel.fromMap(docs[index].data() as Map<String, dynamic>);
              return Card(
                color: alert.handled ? Colors.green[900] : Colors.red[900],
                child: ListTile(
                  title: Text(alert.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(alert.description, style: const TextStyle(color: Colors.white70)),
                  trailing: alert.handled
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : const Icon(Icons.pending, color: Colors.yellowAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
