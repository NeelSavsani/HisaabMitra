import 'package:google_fonts/google_fonts.dart';
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
            // App Logo - Top Left
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

            // Skip Button - Top Right
            Positioned(
              top: 8,
              right: 14,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to Home Screen
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E0D5),
                  foregroundColor: const Color(0xFF29213D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4,),
                    Icon(Icons.fast_forward)
                  ],
                ),
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
                    Text(
                      'Welcome to HisaabMitra!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.chewy(
                        fontSize: 26,
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
