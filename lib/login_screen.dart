import 'package:flutter/material.dart';
import 'package:voteshield/widgets/circular_animation.dart'; // Corrected import path

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false; // Add a loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... your login form elements ...
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Start loading
                });
                // Simulate a login process
                await Future.delayed(const Duration(seconds: 3));
                setState(() {
                  _isLoading = false; // Stop loading
                });
                // ... your navigation logic ...
              },
              child: const Text('Login'),
            ),

            if (_isLoading) // Show the animation when loading
              const CircularAnimation(),
          ],
        ),
      ),
    );
  }
}
