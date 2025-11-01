import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_provider.dart';

// Enum to represent the different states of authentication
enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

// This provider MANAGES the login/logout actions
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  AuthProvider() {
    // Check if the user is already logged in when the app starts
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final bool loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, UserProvider userProvider) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    final response = await _authService.login(email, password);

    if (response['success'] == true && response['user'] != null) {
      // SUCCESS!
      // Tell the UserProvider to store the new user data
      userProvider.setUser(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      // FAILURE
      _errorMessage = response['message'] ?? 'Login failed.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, UserProvider userProvider) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    final response = await _authService.register(name, email, password);

    if (response['success'] == true && response['user'] != null) {
      // SUCCESS!
      userProvider.setUser(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      // FAILURE
      _errorMessage = response['message'] ?? 'Registration failed.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(UserProvider userProvider) async {
    await _authService.logout();
    userProvider.logout(); // Clear the user data
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

