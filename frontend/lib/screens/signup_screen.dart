import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import '../services/user_provider.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- THIS IS THE REGISTER FUNCTION ---
  // It matches the button's 'onPressed: _register'
  Future<void> _register() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // We call the AuthProvider, not the AuthService directly
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      userProvider,
    );

    if (mounted && !success) {
      // Show error message if registration failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
    // If successful, the AuthWrapper in main.dart will automatically
    // navigate to HomeScreen. We also pop this screen.
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
  // --- END OF REGISTER FUNCTION ---

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Background color is from the theme
      appBar: AppBar(
        // The theme makes this transparent with a black back arrow
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your wellness journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // --- NAME TEXT FIELD ---
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 20),

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
                  ),
                  obscureText: true,
                  validator: (value) =>
                  (value == null || value.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 30),

                // --- SIGNUP BUTTON ---
                // This 'onPressed' now correctly calls the '_register' function
                authProvider.status == AuthStatus.authenticating
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _register, // This now matches
                  child: const Text('Sign Up'),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        // Pop this screen to go back to the login screen
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Color(0xFF6B8E23), // Theme green
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

