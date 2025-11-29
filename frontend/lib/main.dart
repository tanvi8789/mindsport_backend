import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/user_provider.dart';
import 'services/mood_provider.dart';
import 'services/reminder_provider.dart';
import 'services/auth_provider.dart';
import 'services/chat_provider.dart';

//import 'services/reminder_service.dart';
//import 'services/auth_service.dart';

// Import all screen files
import 'screens/home_screen.dart';
// Note: You don't need to import auth_service.dart here, it's used by your providers
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/chat_page.dart';
import 'screens/community_forum.dart';
import 'screens/profile_screen.dart';
import 'screens/reminders_screen.dart';
import 'package:mindsport/screens/mood_calender.dart';
// Import placeholder screens
import 'screens/placeholder_screen.dart';

class MindSportTheme {
  static const Color primaryBackground = Color(0xFFF2F0EC); // Your existing warm beige
  static const Color darkText = Color(0xFF252525); // Your existing dark text
  static const Color primaryGreen = Color(0x8B466C3F); // A deep, earthy olive/sage
  static const Color softGreen = Color(0x7C9C7A62); // Your existing mood card color
  static const Color softPeach = Color(0xFFF3CEB3); // From your quote card
  static const Color softLavender = Color(0xFF807EB6); // From your calendar card
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MoodProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MindSportApp(),
    ),
  );
}

class MindSportApp extends StatelessWidget {
  const MindSportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindSport App',
      theme: ThemeData(
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: MindSportTheme.primaryBackground,
        primaryColor: MindSportTheme.primaryGreen,

        // --- App Bar Theme ---
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make all app bars transparent
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: MindSportTheme.darkText), // Black icons
          titleTextStyle: TextStyle(
            color: MindSportTheme.darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),

        // --- Button Theme ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MindSportTheme.primaryGreen, // Earthy green buttons
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded buttons
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ),

        // --- Text Field Theme ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          hintStyle: const TextStyle(color: Colors.black38),
          // This creates the "soft, no underline" look
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // No border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MindSportTheme.primaryGreen, width: 2),
          ),
        ),

        // --- Card Theme ---
        cardTheme: CardThemeData (
          elevation: 0, // No shadow for a flatter, softer look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const AuthWrapper(),
      // --- THIS IS THE UPDATED ROUTES MAP ---
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/reminders': (context) => const RemindersScreen(),
        // --- THESE ARE THE NEW LINES ---
        '/profile': (context) => const ProfileScreen(),
        '/forum': (context) => CommunityForum(),
        '/chat': (context) => ChatPage(),
        '/history': (context) => const MoodHistoryScreen(),
      },
    );
  }
}

/// AuthWrapper
/// This is a new, smart widget that handles showing the
/// correct screen based on whether the user is logged in.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We watch the AuthProvider for any changes in login status
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.authenticated:
      // User is logged in, show the Home Screen
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      // User is logged out, show the Login Screen
        return const LoginScreen();
      case AuthStatus.authenticating:
      case AuthStatus.uninitialized:
      default:
      // Show a loading circle while we check their login status
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
