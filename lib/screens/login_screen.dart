import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon
              const Icon(
                Icons.bolt_rounded,
                size: 100,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              
              // App Branding
              const Text(
                'Power Task',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'The SaaS To-Do App',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),

              // Main Login Button
              ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(280, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  try {
                    await AuthService().signInWithGoogle();
                  } catch (e) {
                    // Show error if login fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login Failed: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 30),

              // Emergency Reset / Troubleshooting Button
              // This clears the browser session if you are stuck in a redirect loop
              TextButton(
                onPressed: () async {
                  try {
                    await AuthService().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session Reset. Please try signing in again."),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    print("Reset error: $e");
                  }
                },
                child: const Text(
                  'Trouble signing in? Click to reset session',
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}