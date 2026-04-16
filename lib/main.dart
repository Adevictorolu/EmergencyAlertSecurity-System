import 'package:dualert/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/sign_in_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/admin_home.dart';
import 'screens/student_home.dart';
import 'screens/view_alert_page.dart';
import 'screens/onboarding_screen.dart';
import 'screens/analytics_page.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';
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
          create: (context) => context.read<AuthService>().authStateChanges,
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
              '/signin': (_) => const SignInPage(),
              '/signup': (_) => const SignUpPage(),
              '/student': (_) => const StudentHome(), // Maps to "Report Emergency"
              '/admin': (_) => const AdminHome(),
              '/history': (_) => const ViewAlertPage(),
              '/analytics': (_) => const AnalyticsPage(),
            },
            home: seenOnboarding ? const AuthWrapper() : const OnboardingScreen(),
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
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    final userProvider = context.read<UserProvider>();

    if (firebaseUser == null) {
      if (_started) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) userProvider.stop();
        });
        _started = false;
      }
      return const SignInPage();
    }

    if (!_started) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) userProvider.start(firebaseUser.uid);
      });
      _started = true;
    }

    final appUser = context.watch<UserProvider>().user;
    if (appUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (appUser.role == 'admin') {
      return const AdminHome();
    }
    return const StudentHome();
  }
}
