
import 'package:flutter/material.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  static const Color backgroundColor = Color(0xFFFDF9E8);
  static const Color primaryColor = Color(0xFF7041E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // App Logo - Fixed at top-left corner
            Positioned(
              top: 8,
              left: 14,
              child: Image.asset(
                'assets/images/common_logo.png',
                width: 105,
                height: 45,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),

            // Main Onboarding Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),

                    // Welcome Heading
                    const Text(
                      'Welcome to HisaabMitra!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29213D),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    const Text(
                      'Managing money should be simple, not stressful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF77717F),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    const Text(
                      'Track expenses, manage your spending, '
                          'and keep your finances organized — '
                          'all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF77717F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
