
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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

                    // Onboarding Illustration
                    Image.asset(
                      'assets/images/onboard_1.png',
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),

                    // Heading
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Your Money\n',
                            style: GoogleFonts.chewy(
                              fontSize: 48,
                              color: const Color(0xFF494323),
                            ),
                          ),
                          TextSpan(
                            text: 'Buddy Awaits!',
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

                    const SizedBox(height: 15),

                    // Description
                    const SizedBox(
                      width: 300,
                      child: Text(
                        'Ready to take control of your money? Join HissabMitra and make tracking expenses, managing income and splitting bills easier than ever.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF77717F),
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
                bottom: 10
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Create Account
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to next onboarding page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFDDC35),
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
                            'Create Your Account',
                            style: TextStyle(
                              color: Colors.black,
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

                  // Login Button
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
                        backgroundColor: primaryColor,
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
                            'Login To Your Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8,),

                  // or
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 1,
                        color: Colors.black,
                      ),

                      SizedBox(width: 20,),

                      Text(
                        'Or',
                        style: TextStyle(
                          fontSize: 16
                        ),
                      ),

                      SizedBox(width: 20,),

                      Container(
                        width: 110,
                        height: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),

                  SizedBox(height: 8,),

                  // Google Button
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
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(
                          color: Color(0xFF494323),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                width: 20,
                                height: 20,
                              ),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 5,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
