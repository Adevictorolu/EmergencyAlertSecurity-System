import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dualert/core/theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isVerified = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    // Poll every 3 seconds — on verification, AuthWrapper will auto-navigate
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isVerified && mounted) {
        _checkEmailVerification(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    
    // Reload user from Firebase servers to get the latest emailVerified status.
    // Critical on web: emailVerified is cached in the JWT and won't update
    // automatically when the user clicks the verification link in another tab.
    try {
      await _auth.currentUser?.reload();
    } catch (_) {
      // ignore errors during reload
    }
    
    final verified = _auth.currentUser?.emailVerified ?? false;
    
    if (mounted) {
      setState(() {
        _isVerified = verified;
        if (showLoading) _isLoading = false;
      });
    }

    // If verified, the AuthWrapper is watching userChanges stream.
    // After reload(), Firebase will emit a new event and AuthWrapper will
    // automatically navigate to StudentHome or AdminHome.
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);
    
    try {
      await _auth.currentUser?.sendEmailVerification();
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _isVerified; // Only allow back if verified
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Verify Email'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: _isVerified,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVerified
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.primaryBlue.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      _isVerified ? Icons.check_circle : Icons.mail_outline,
                      size: 50,
                      color: _isVerified ? AppColors.success : AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isVerified ? 'Email Verified!' : 'Verify Your Email',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _isVerified
                      ? 'Your email has been successfully verified. You can now use all features of DUalert.'
                      : 'We sent a verification email to ${_auth.currentUser?.email ?? "your email"}. Please click the link in the email to verify your account.',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_isVerified) ...[
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkEmailVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Check Verification Status',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _resendVerificationEmail,
                    child: const Text(
                      'Resend Verification Email',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () async {
                      // Force reload to emit a new userChanges event.
                      // AuthWrapper will detect emailVerified=true and navigate automatically.
                      try {
                        await _auth.currentUser?.reload();
                      } catch (_) {}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
