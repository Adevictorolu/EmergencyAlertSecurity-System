import 'package:dualert/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dualert/features/auth/services/auth_service.dart';
import 'providers/user_provider.dart';
import 'package:dualert/features/auth/screens/sign_in_page.dart';
import 'package:dualert/features/auth/screens/sign_up_page.dart';
import 'package:dualert/features/dashboard/screens/admin_home.dart';
import 'package:dualert/features/emergency/screens/student_home.dart';
import 'package:dualert/features/dashboard/screens/view_alert_page.dart';
import 'package:dualert/features/auth/screens/onboarding_screen.dart';
import 'package:dualert/features/dashboard/screens/analytics_page.dart';
import 'package:dualert/features/auth/screens/email_verification_screen.dart';
import 'package:dualert/features/settings/screens/settings_screen.dart';
import 'package:dualert/core/theme/app_colors.dart';
import 'package:dualert/core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(DualertApp(seenOnboarding: seenOnboarding));
}

class DualertApp extends StatelessWidget {
  final bool seenOnboarding;

  const DualertApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().userChanges,
          initialData: null,
        ),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "DUalert",
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routes: {
              '/auth': (_) => const AuthWrapper(),
              '/signin': (_) => const SignInPage(),
              '/signup': (_) => const SignUpPage(),
              '/student': (_) =>
                  const StudentHome(), // Maps to "Report Emergency"
              '/admin': (_) => const AdminHome(),
              '/history': (_) => const ViewAlertPage(),
              '/analytics': (_) => const AnalyticsPage(),
              '/settings': (_) => const SettingsScreen(),
              '/verification': (_) => const EmailVerificationScreen(),
            },
            home: seenOnboarding
                ? const AuthWrapper()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Track which UID we started the provider for, to handle sign-out/sign-in correctly.
  String? _startedForUid;
  bool _reloading = false;

  /// Reloads the Firebase user token to get a fresh emailVerified status.
  /// This is critical on web where emailVerified is cached from the initial token.
  Future<void> _reloadUser(User user) async {
    if (_reloading) return;
    _reloading = true;
    try {
      await user.reload();
    } catch (_) {
      // ignore reload errors
    } finally {
      if (mounted) setState(() => _reloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>() ?? FirebaseAuth.instance.currentUser;
    final userProvider = context.read<UserProvider>();
    final userProviderState = context.watch<UserProvider>();

    if (firebaseUser == null) {
      // User signed out — clean up provider
      if (_startedForUid != null) {
        _startedForUid = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) userProvider.stop();
        });
      }
      return const SignInPage();
    }

    // On web, emailVerified is cached in the JWT token. We must call reload()
    // to get the latest status from Firebase servers.
    if (!firebaseUser.emailVerified) {
      // Trigger a background reload so the stream refreshes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reloadUser(firebaseUser);
      });
      return const EmailVerificationScreen();
    }

    // Start listening to the user's Firestore document if not already started
    // for this specific user UID.
    if (_startedForUid != firebaseUser.uid) {
      if (_startedForUid != null) {
        // Different user logged in — stop the old subscription first
        userProvider.stop();
      }
      _startedForUid = firebaseUser.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) userProvider.start(firebaseUser.uid);
      });
    }

    if (userProviderState.user == null) {
      if (userProviderState.isLoading) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        );
      }

      // If the profile document is temporarily unavailable, avoid bouncing users back to sign-in.
      return const StudentHome();
    }

    if (userProviderState.user!.role == 'admin') {
      return const AdminHome();
    }
    return const StudentHome();
  }
}
