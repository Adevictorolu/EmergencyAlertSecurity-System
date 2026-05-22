import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dualert/features/auth/services/auth_service.dart';
import 'package:dualert/providers/user_provider.dart';
import 'package:dualert/core/theme/app_colors.dart';
import 'package:dualert/features/emergency/widgets/speech_input_widget.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  bool customLoading = false;
  bool emergencyLoading = false;

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _triggerSOS(AuthService auth, String uid) async {
    setState(() => emergencyLoading = true);
    try {
      await auth.createAlert(
        uid: uid,
        title: 'EMERGENCY SOS',
        description: 'Immediate help needed! SOS triggered remotely.',
      );
      _showSuccess('Emergency alert sent!');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => emergencyLoading = false);
    }
  }

  Future<void> _submitCustomAlert(AuthService auth, String uid) async {
    if (titleC.text.trim().isEmpty || descC.text.trim().isEmpty) {
      _showError('Please enter a title and description.');
      return;
    }

    setState(() => customLoading = true);
    try {
      await auth.createAlert(
        uid: uid,
        title: titleC.text.trim(),
        description: descC.text.trim(),
      );
      titleC.clear();
      descC.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _showSuccess('Alert submitted successfully!');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => customLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    final isAdmin = user.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Report Emergency'),
        centerTitle: false,
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Dashboard',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'System Analytics',
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'General Alert History',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async => await auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Are you in immediate danger?',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the SOS button to instantly alert security with your current location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // SOS Button
              GestureDetector(
                onTap: emergencyLoading
                    ? null
                    : () => _triggerSOS(auth, user.uid),
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  alignment: Alignment.center,
                  child: emergencyLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 36,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 50),
              const Divider(color: AppColors.textSecondary, thickness: 0.2),
              const SizedBox(height: 30),

              // Quick Alerts
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Alerts',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickBox(
                    auth,
                    user.uid,
                    'Fire',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildQuickBox(
                    auth,
                    user.uid,
                    'Medical',
                    Icons.medical_services,
                    Colors.blue,
                  ),
                  _buildQuickBox(
                    auth,
                    user.uid,
                    'Security',
                    Icons.security,
                    Colors.green,
                  ),
                  _buildQuickBox(
                    auth,
                    user.uid,
                    'Other',
                    Icons.more_horiz,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(color: AppColors.textSecondary, thickness: 0.2),
              const SizedBox(height: 30),

              // Custom Alert Form
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Report a specific incident',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleC,
                        style: const TextStyle(fontFamily: 'Montserrat'),
                        decoration: InputDecoration(
                          hintText: 'Emergency Type (e.g. Fire, Medical)',
                          prefixIcon: const Icon(
                            Icons.title,
                            color: AppColors.textSecondary,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: descC,
                              maxLines: 3,
                              style: const TextStyle(fontFamily: 'Montserrat'),
                              decoration: InputDecoration(
                                hintText: 'Describe the situation and location...',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SpeechInputWidget(
                            controller: descC,
                            onTextRecognized: (newText) {
                              descC.text = newText;
                              descC.selection = TextSelection.fromPosition(
                                TextPosition(offset: descC.text.length),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: customLoading
                              ? null
                              : () => _submitCustomAlert(auth, user.uid),
                          icon: customLoading
                              ? const SizedBox()
                              : const Icon(Icons.send_rounded, size: 20),
                          label: customLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Submit Alert',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickBox(
    AuthService auth,
    String uid,
    String type,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Trigger $type Alert?'),
            content: Text(
              'This will instantly notify everyone about a $type emergency.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await auth.createAlert(
              uid: uid,
              title: type,
              description: 'Immediate $type emergency reported.',
            );
            _showSuccess('$type alert sent!');
          } catch (e) {
            _showError(e.toString());
          }
        }
      },
      child: Container(
        width: 70,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
