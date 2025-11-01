import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
        return;
      }

      setState(() { _isLoading = true; });

      final result = await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check if the widget is still in the tree before updating state
      if (!mounted) return;

      setState(() { _isLoading = false; });

      if (result['success']) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Safely get the error message, provide a default if it's null
        final message = result['message'] as String? ?? 'An unknown error occurred.';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
  }

  // ... The rest of your build method for the UI ...
  @override
  Widget build(BuildContext context) {
    // Paste your existing build method here.
    // The UI doesn't need to change, only the _signUp logic.
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text( 'Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A),),),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration( labelText: 'Name', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12),),),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration( labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12),),),
                    validator: (value) => value == null || !value.contains('@') ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration( labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12),),),
                    validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration( labelText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12),),),
                    validator: (value) => value == null || value.isEmpty ? 'Please confirm your password' : null,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFFD5DABA), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12),),),
                    child: const Text( 'Sign Up', style: TextStyle(fontSize: 18, color: Colors.black87),),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                    child: const Text( 'Already have an account? Login', style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

