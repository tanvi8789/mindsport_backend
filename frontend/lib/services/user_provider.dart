import 'package:flutter/material.dart';
import '../models/user_model.dart'; // We need our new model
import 'auth_service.dart';

// This provider HOLDS the user's data
class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService();

  // Set the user data (called by AuthProvider after login)
  void setUser(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    notifyListeners();
  }

  // Clear user data on logout
  void logout() {
    _user = null;
    notifyListeners();
  }

  // Fetch user data from server (called on app start)
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    final userData = await _authService.getUserData();
    if (userData != null) {
      _user = User.fromJson(userData);
    }

    _isLoading = false;
    notifyListeners();
  }
}

