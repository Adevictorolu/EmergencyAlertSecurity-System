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
          if (alertSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!alertSnapshot.hasData || alertSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No alerts yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final alerts = alertSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
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
                      senderSnapshot.data!.data() as Map<String, dynamic>? ?? {};

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: alert.handled ? Colors.green[900] : Colors.red[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        alert.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
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
                          if (alert.lat != null && alert.lng != null)
                            Text(
                              "Location: (${alert.lat}, ${alert.lng})",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          const SizedBox(height: 5),
                          Text(
                            "Status: ${alert.handled ? "Handled" : "Pending"}",
                            style: TextStyle(
                                color: alert.handled
                                    ? Colors.greenAccent
                                    : Colors.yellowAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: alert.handled
                          ? const Icon(Icons.check, color: Colors.greenAccent)
                          : IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () async {
                                final adminUid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                await AuthService().handleAlert(
                                  alert.id,
                                  adminUid,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Alert marked as handled'),
                                  ),
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
