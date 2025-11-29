import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import '../services/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- FIX: We no longer need these ---
  // final AuthService _authService = AuthService(); // We will use AuthProvider
  // bool _isLoading = false; // AuthProvider will handle this

  bool _isPasswordVisible = false; // We can keep this if you add a toggle

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- THIS IS THE CORRECTED _login FUNCTION ---
  Future<void> _login() async {
    // Check if the form fields are valid
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Get the providers (listen: false because we are in a function)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Call the login method from the AuthProvider
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      userProvider,
    );

    // Check if the widget is still mounted before showing an error
    if (!mounted) return;

    // If login failed, show the error message from the provider
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }

    // --- WE DO NOT NAVIGATE HERE ---
    // The AuthWrapper in main.dart will automatically handle
    // navigation when the authProvider.status changes.
    // We can remove the old logic:
    // if (result['success']) { ... }
  }
  // --- END OF CORRECTED FUNCTION ---

  @override
  Widget build(BuildContext context) {
    // Get the AuthProvider to listen for state changes
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // The background color is now set from the theme in main.dart
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.spa, // Example icon (Spa/Wellness)
                  size: 80,
                  color: Color(0xFF6B8E23), // Using the new primary green
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // --- EMAIL TEXT FIELD ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  (value == null || !value.contains('@'))
                      ? 'Please enter a valid email'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- PASSWORD TEXT FIELD ---
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    // You could add a visibility toggle here:
                    // suffixIcon: IconButton(
                    //   icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    //   onPressed: () => setState(() { _isPasswordVisible = !_isPasswordVisible; }),
                    // ),
                  ),
                  obscureText: !_isPasswordVisible, // Use the state variable
                  validator: (value) =>
                  (value == null || value.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 30),

                // --- LOGIN BUTTON ---
                // This correctly listens to the provider's status
                authProvider.status == AuthStatus.authenticating
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _login, // This now calls our corrected _login function
                  child: const Text('Login'),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF6B8E23),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

