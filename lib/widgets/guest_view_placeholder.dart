import 'package:flutter/material.dart';

class GuestViewPlaceholder extends StatelessWidget {
  final String iconType; // 'person', 'favorite', 'list'
  final String message;
  final String submessage;
  final VoidCallback onSignIn;

  const GuestViewPlaceholder({
    required this.iconType,
    required this.message,
    required this.submessage,
    required this.onSignIn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.person_outline;
    if (iconType == 'favorite') {
      icon = Icons.favorite_outline;
    } else if (iconType == 'list') {
      icon = Icons.checklist_outlined;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                submessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
