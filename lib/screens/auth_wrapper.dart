import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'login_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        if (!user.emailVerified) {
          return const EmailVerificationWaitingScreen();
        }

        return const MainScreen();
      },
    );
  }
}

class EmailVerificationWaitingScreen extends StatefulWidget {
  const EmailVerificationWaitingScreen({super.key});

  @override
  State<EmailVerificationWaitingScreen> createState() => _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState extends State<EmailVerificationWaitingScreen> {
  Timer? _timer;
  bool _verificationDetected = false;

  @override
  void initState() {
    super.initState();
    // Check verification status every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkVerification();
    });
    // Initial check right away
    _checkVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    try {
      // Reload user data to get latest emailVerified status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        
        // Check again after reload
        final updatedUser = FirebaseAuth.instance.currentUser;
        
        if (updatedUser != null && updatedUser.emailVerified && !_verificationDetected && mounted) {
          _verificationDetected = true;
          
          // Show success snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Email verified! Welcome to Organic Food Directory'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Stop the timer
          _timer?.cancel();

          // Wait for snackbar to be visible, then navigate to MainScreen
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            // Navigate directly to MainScreen instead of waiting for stream rebuild
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      }
    } catch (e) {
      // Silent fail — timer will retry
      debugPrint('Verification check error: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified && mounted) {
      try {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent! Check inbox/spam.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resend: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We sent a verification link to your email.\n\n'
                'Please check your inbox (including spam/junk folder) and click the link.\n\n'
                'The app will automatically continue once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _resendVerificationEmail,
                icon: const Icon(Icons.refresh),
                label: const Text('Resend Verification Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
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
