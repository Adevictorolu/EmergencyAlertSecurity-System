import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_11/firebase_options.dart';
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
        darkTheme: ThemeData.dark(
          useMaterial3: true
        ),
        theme: ThemeData(
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final firebaseUser = context.watch<User?>();
    final userProv = Provider.of<UserProvider>(context, listen: false);

    // Start listening only once
    if (firebaseUser != null && !_started) {
      userProv.start(firebaseUser.uid);
      _started = true;
    }

    // Stop listening if signed out
    if (firebaseUser == null && _started) {
      userProv.stop();
      _started = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    final userProv = Provider.of<UserProvider>(context);

    // Not signed in → SignInPage
    if (firebaseUser == null) return const SignInPage();

    // Still loading user data → show loading indicator
    if (userProv.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Navigate based on role
    return userProv.user!.role == 'admin'
        ? const AdminHome()
        : const StudentHome();
  }
}
