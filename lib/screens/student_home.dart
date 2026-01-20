import 'package:DUALERT/auth/auth_service.dart';
import 'package:DUALERT/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final uid = user?.uid;

    if (uid != null) {
      Provider.of<UserProvider>(context, listen: false).start(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard (${user.email})'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.view_headline_rounded),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: loading
                  ? null
                  : () async {
                      setState(() => loading = true);
                      try {
                        await auth.createAlert(
                          uid: user.uid,
                          title: 'EMERGENCY',
                          description: 'Immediate help needed!',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Emergency alert sent!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        setState(() => loading = false);
                      }
                    },
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.deepOrangeAccent],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleC,
              decoration: const InputDecoration(hintText: 'Alert Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descC,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: loading
                  ? null
                  : () async {
                      setState(() => loading = true);
                      try {
                        await auth.createAlert(
                          uid: user.uid,
                          title: titleC.text.trim(),
                          description: descC.text.trim(),
                        );
                        titleC.clear();
                        descC.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alert submitted!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        setState(() => loading = false);
                      }
                    },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueAccent,
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Alert',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('alerts')
                    .where('uid', isEqualTo: user.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No alerts yet.'));
                  }

                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data()! as Map<String, dynamic>;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final formattedTime = timestamp != null
                          ? DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(timestamp.toDate())
                          : 'Unknown';
                      final handled = data['handled'] ?? false;
                      final lat = data['lat'] ?? 'Unknown';
                      final lng = data['lng'] ?? 'Unknown';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(data['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['description'] ?? ''),
                              Text('Location: ($lat, $lng)'),
                              Text(
                                'Status: ${handled ? "Handled" : "Pending"}',
                              ),
                              Text('Time: $formattedTime'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
