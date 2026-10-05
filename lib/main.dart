import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_page.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme from SharedPreferences before app starts
  await ThemeManager.init();

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
  // Keeps MasroufiApp.of(context).toggleTheme() working and saves to SharedPreferences!
  void toggleTheme() {
    final newIsDark = !ThemeManager.isDarkMode;
    ThemeManager.toggleTheme(newIsDark);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Masroufi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode, // Defined by ValueListenableBuilder above!
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
      },
    );
  }
}