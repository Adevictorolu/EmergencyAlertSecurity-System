import 'package:DUALERT/firebase_options.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        title: "DUALERT",
        theme: ThemeData(
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: const Color.fromARGB(255, 56, 45, 45),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.blueAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(0, 255, 255, 255),
            elevation: 0,
          ),
        ),
        routes: {
          '/signin': (_) => const SignInPage(),
          '/signup': (_) => const SignUpPage(),
          '/student': (_) => const StudentHome(),
          '/admin': (_) => const AdminHome(),
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
        userProvider.stop(); 
        _started = false;
      }
      return const SignInPage();
    }
    if (!_started) {
      userProvider.start(firebaseUser.uid);
      _started = true;
    }

    final appUser = context.watch<UserProvider>().user;
    if (appUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
