import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'firebase_options.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_page.dart';
//hello

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Connects to your specific "Masroufi" project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MasroufiApp());
}

class MasroufiApp extends StatefulWidget {
  const MasroufiApp({super.key});

  static MasroufiAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MasroufiAppState>()!;

  @override
  State<MasroufiApp> createState() => MasroufiAppState();
}

class MasroufiAppState extends State<MasroufiApp> {
  // Changed default to Light Mode
  ThemeMode _themeMode = ThemeMode.light; 

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masroufi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Use StreamBuilder to listen to Auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in, show the Dashboard
          if (snapshot.hasData) {
            return const MainNavigation();
          }
          // Otherwise, show the Login screen
          return const AuthPage();
        },
      ),
    );
  }
}