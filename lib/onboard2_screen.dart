
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisaabmitra/welcome_screen.dart';

import 'onboard_screen.dart';

class OnboardScreen2 extends StatelessWidget {
  const OnboardScreen2({super.key});

  static const Color backgroundColor = Color(0xFFFDF9E8);
  static const Color primaryColor = Color(0xFF8078F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top section: Logo and Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/common_logo.png',
                    width: 105,
                    height: 45,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),

            // Main onboarding content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 5),

                    // Onboarding Illustration
                    Image.asset(
                      'assets/images/onboard_1.png',
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 12),

                    // Heading
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Your Hisaab\n',
                            style: GoogleFonts.chewy(
                              fontSize: 48,
                              color: const Color(0xFF494323),
                            ),
                          ),
                          TextSpan(
                            text: 'Made Super Easy',
                            style: GoogleFonts.chewy(
                              fontSize: 48,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      strutStyle: const StrutStyle(
                        height: 3,
                        forceStrutHeight: true,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Description
                    const SizedBox(
                      width: 300,
                      child: Text(
                        'From tracking every rupee to splitting bills with friends, everything you need to manage your money is right here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF77717F),
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    SizedBox(
                      width: 300,
                      child: Text(
                        'Less Calculation, More Celebration!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chewy(
                          fontSize: 18,
                          color: Color(0xFF494323)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section: Page indicators and Next button
            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
                bottom: 25,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6D6D6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD92F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD2D2D2),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
