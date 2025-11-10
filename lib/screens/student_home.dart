

import 'package:DUALERT/auth/auth_service.dart';
import 'package:DUALERT/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await auth.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 🔴 BIG EMERGENCY BUTTON
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
                          const SnackBar(content: Text('Emergency alert sent!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
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
                    )
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
            const SizedBox(height: 40),
            // Optional: custom alert form
            TextField(
              controller: titleC,
              decoration: const InputDecoration(hintText: 'Alert Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descC,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 20),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setState(() => loading = false);
                      }
                    },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.blueAccent, blurRadius: 12, spreadRadius: 1)
                  ],
                ),
                alignment: Alignment.center,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Alert',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
