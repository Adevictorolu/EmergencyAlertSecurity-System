import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final fullC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final matricC = TextEditingController();
  final phoneC = TextEditingController();
  final adminCodeC = TextEditingController();
  bool isAdmin = false;
  bool loading = false;

  static const expectedAdminCode = 'DUALERT-ADMIN-2025';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(controller: fullC, decoration: const InputDecoration(hintText: 'Full Name')),
            const SizedBox(height: 15),
            TextField(controller: emailC, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 15),
            TextField(controller: passC, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text('Sign up as Admin'),
              value: isAdmin,
              onChanged: (val) => setState(() => isAdmin = val),
            ),
            if (!isAdmin) ...[
              TextField(controller: matricC, decoration: const InputDecoration(hintText: 'Matric No')),
              const SizedBox(height: 15),
              TextField(controller: phoneC, decoration: const InputDecoration(hintText: 'Phone')),
            ] else
              TextField(controller: adminCodeC, decoration: const InputDecoration(hintText: 'Admin Code')),
            const SizedBox(height: 30),
            InkWell(
              onTap: loading ? null : () async {
                setState(() => loading = true);
                try {
                  if (isAdmin) {
                    await auth.signUpAsAdmin(
                      fullName: fullC.text.trim(),
                      email: emailC.text.trim(),
                      password: passC.text.trim(),
                      adminCode: adminCodeC.text.trim(),
                      expectedAdminCode: expectedAdminCode,
                    );
                  } else {
                    await auth.signUpAsStudent(
                      fullName: fullC.text.trim(),
                      email: emailC.text.trim(),
                      password: passC.text.trim(),
                      matricNo: matricC.text.trim(),
                      phone: phoneC.text.trim(),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  setState(() => loading = false);
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.blueAccent, blurRadius: 12, spreadRadius: 1)],
                ),
                alignment: Alignment.center,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
