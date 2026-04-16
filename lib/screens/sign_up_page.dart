import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../utils/app_colors.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Successfully created account. A verification email was sent!',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textLight,
              ),
            ),
            backgroundColor: AppColors.error,
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
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.background),
                        ),
                        child: SwitchListTile(
                          activeColor: AppColors.primaryBlue,
                          title: const Text(
                            'Sign up as Admin',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                            shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textLight,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
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
                    color: AppColors.textSecondary,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.primaryBlue,
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
