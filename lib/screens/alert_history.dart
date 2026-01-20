import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AlertHistoryPage extends StatelessWidget {
  const AlertHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final alertsQuery = user.role == 'admin'
        ? FirebaseFirestore.instance
              .collection('alerts')
              .orderBy('timestamp', descending: true)
        : FirebaseFirestore.instance
              .collection('alerts')
              .where('uid', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Alert History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: alertsQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No alerts found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final handled = data['handled'] ?? false;
              final lat = data['lat'] ?? 'Unknown';
              final lng = data['lng'] ?? 'Unknown';
              final senderUid = data['uid'] ?? 'Unknown';

              return Card(
                color: handled ? Colors.grey[300] : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? ''),
                      Text('Status: ${handled ? "Handled" : "Pending"}'),
                      Text('Location: ($lat, $lng)'),
                      Text('Sender UID: $senderUid'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
