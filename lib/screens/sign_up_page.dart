import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final fullC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final matricC = TextEditingController();
  final phoneC = TextEditingController();
  final adminCodeC = TextEditingController();

  bool isAdmin = false;
  bool loading = false;
  bool _obscureText = true;

  static const expectedAdminCode = 'DUALERT-ADMIN-2025';

  @override
  void dispose() {
    fullC.dispose();
    emailC.dispose();
    passC.dispose();
    matricC.dispose();
    phoneC.dispose();
    adminCodeC.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
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
      if (mounted) {
        Navigator.pop(
          context,
        ); // Optional: successfully signed up, back to sign in
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}",
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFFADB5BD),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFADB5BD)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFADB5BD),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1E3C72), width: 1.5),
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern subtle background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(
                        controller: fullC,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        controller: emailC,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        controller: passC,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile(
                          activeColor: const Color(0xFF1E3C72),
                          title: const Text(
                            'Sign up as Admin',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF495057),
                            ),
                          ),
                          value: isAdmin,
                          onChanged: (val) => setState(() => isAdmin = val),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!isAdmin) ...[
                        _buildTextField(
                          controller: matricC,
                          label: 'Matric Number',
                          icon: Icons.badge_outlined,
                        ),
                        _buildTextField(
                          controller: phoneC,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ] else
                        _buildTextField(
                          controller: adminCodeC,
                          label: 'Admin Code',
                          icon: Icons.admin_panel_settings_outlined,
                          isPassword: true,
                        ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3C72).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1E3C72),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
