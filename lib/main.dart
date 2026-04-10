import 'package:dualert/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/sign_in_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/student_home.dart';
import 'screens/admin_home.dart';
import 'screens/view_alert_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DualertApp());
}

class DualertApp extends StatelessWidget {
  const DualertApp({super.key});

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "DUalert",
        theme: ThemeData(
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: const Color(
            0xFFF5F7FA,
          ), // Modern subtle background
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3C72),
            primary: const Color(0xFF1E3C72),
            secondary: const Color(0xFF2A5298),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        routes: {
          '/signin': (_) => const SignInPage(),
          '/signup': (_) => const SignUpPage(),
          '/student': (_) => const StudentHome(),
          '/admin': (_) => const AdminHome(),
          '/history': (_) =>
              const ViewAlertPage(), // Fixed undefined route crash
        },
        home: const AuthWrapper(),
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
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3C72)),
          ),
        ),
      );
    }

    switch (appUser.role) {
      case 'admin':
        return const AdminHome();
      case 'student':
        return const StudentHome();
      default:
        return const SignInPage();
    }
  }
}
