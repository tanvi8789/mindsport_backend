import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/user_provider.dart';
import 'services/mood_provider.dart';
import 'services/reminder_provider.dart';
import 'services/auth_provider.dart';

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
// Import placeholder screens
import 'screens/placeholder_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MoodProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
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
        scaffoldBackgroundColor: const Color(0xFFF2F0EC),
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
