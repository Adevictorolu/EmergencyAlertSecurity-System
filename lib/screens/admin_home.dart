import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/alert_model.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final _ = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await auth.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('alerts').get(),
        builder: (context, alertSnapshot) {
          if (!alertSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alerts = alertSnapshot.data!.docs;

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alertData = alerts[index].data() as Map<String, dynamic>;
              final alert = AlertModel.fromMap(alertData);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(alert.senderUid)
                    .get(),
                builder: (context, senderSnapshot) {
                  if (!senderSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Loading sender info..."),
                    );
                  }

                  final senderData =
                      senderSnapshot.data!.data() as Map<String, dynamic>? ??
                      {};

                  return Card(
                    color: alert.handled ? Colors.green[900] : Colors.red[900],
                    child: ListTile(
                      title: Text(
                        alert.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.description,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Sender: ${senderData['fullName'] ?? 'Unknown'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Email: ${senderData['email'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (senderData['phone'] != null)
                            Text(
                              "Phone: ${senderData['phone']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      trailing: alert.handled
                          ? const Icon(Icons.check, color: Colors.greenAccent)
                          : IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () async {
                                final adminUid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                await AuthService().handleAlert(
                                  alert.id,
                                  adminUid,
                                );
                              },
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
