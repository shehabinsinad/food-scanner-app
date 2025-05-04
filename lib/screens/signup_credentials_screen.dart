import 'package:flutter/material.dart';
import 'package:food_scanner_app/services/auth_service.dart';

class SignupCredentialsScreen extends StatefulWidget {
  const SignupCredentialsScreen({Key? key}) : super(key: key);

  @override
  _SignupCredentialsScreenState createState() => _SignupCredentialsScreenState();
}

class _SignupCredentialsScreenState extends State<SignupCredentialsScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _next() async {
    setState(() {
      _isLoading = true;
    });
    final result = await _authService.signUpWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (result == null) {
      // Proceed to the preferences page if signup succeeded.
      Navigator.pushReplacementNamed(context, '/signup_preferences');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up - Credentials")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: emailController,
              decoration: _buildInputDecoration("Email"),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: _buildInputDecoration("Password"),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _next,
                    child: const Text("Next", style: TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }
}
