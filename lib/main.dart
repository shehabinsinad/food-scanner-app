import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/screens/landing_screen.dart';
import 'package:food_scanner_app/screens/login_screen.dart';
import 'package:food_scanner_app/screens/signup_credentials_screen.dart';
import 'package:food_scanner_app/screens/signup_preferences_screen.dart';
import 'package:food_scanner_app/screens/home_screen.dart';
import 'package:food_scanner_app/screens/scanner_screen.dart';
import 'package:food_scanner_app/screens/update_preferences_screen.dart';
import 'package:food_scanner_app/screens/results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Scanner App',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          fontFamily: 'Lato',
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF121212),
            secondary: const Color(0xFFFFD400),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD400),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: '/landing',
        routes: {
          '/landing': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup_credentials': (context) => const SignupCredentialsScreen(),
          '/signup_preferences': (context) => const SignupPreferencesScreen(),
          '/home': (context) => const HomeScreen(),
          '/scanner': (context) => const ScannerScreen(),
          '/update_preferences': (context) => const UpdatePreferencesScreen(),
          '/results': (context) => const ResultsScreen(),
        },
      ),
    );
  }
}
