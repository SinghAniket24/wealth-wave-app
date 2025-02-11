import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stocks/pages/auth_service.dart'; // Correct import path for AuthService
import 'package:stocks/pages/home_page.dart'; // Ensure this matches your home page file

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? result = await _authService.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      "", // ✅ Added empty string for the profile image URL
    );

    setState(() => _isLoading = false);

    if (result == null) {
      _showVerificationDialog();
    } else {
      setState(() => _errorMessage = result);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    String? result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()), // Ensure HomePage is correct
      );
    } else {
      setState(() => _errorMessage = result);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: const Text(
          "A verification email has been sent to your inbox. Please verify before logging in.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut(); // Ensure user logs out after sign-up
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView( // ✅ Fix RenderFlex overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (value) => value!.isEmpty ? "Enter your name" : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.contains("@") ? null : "Enter a valid email",
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) => value!.length >= 6 ? null : "Password must be 6+ chars",
                    ),
                    const SizedBox(height: 10),
                    if (_errorMessage != null)
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signUp,
                            child: const Text("Sign Up"),
                          ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      child: const Text("Sign Up with Google"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
