import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color backgroundColor = Color(0xFFFDF9E8);
  static const Color primaryColor = Color(0xFF8078F9);
  static const Color textColor = Color(0xFF494323);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTermsAccepted = false;
  bool _isRegistering = false;

  bool get _canRegister =>
      nameController.text.trim().isNotEmpty &&
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(emailController.text.trim()) &&
      passwordController.text.length >= 8 &&
      confirmPasswordController.text.isNotEmpty &&
      confirmPasswordController.text == passwordController.text &&
      isTermsAccepted;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isRegistering) return;
    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions.'),
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);
    try {
      await AuthService().register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        final message = switch (error.code) {
          'email-already-in-use' => 'An account already exists for this email.',
          'invalid-email' => 'Please enter a valid email address.',
          'weak-password' => 'Please choose a stronger password.',
          _ =>
            error.message ?? 'Unable to create your account. Please try again.',
        };
        _showError(message);
      }
    } catch (_) {
      if (mounted) _showError('Unable to save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Common input decoration
  InputDecoration inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFDF5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFE7E2D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: primaryColor, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  // Common field label
  Widget fieldLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black87),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Password strength calculation
  int get passwordStrength {
    String password = passwordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }

    return strength;
  }

  String get strengthLabel {
    if (passwordController.text.isEmpty) return '';
    if (passwordStrength <= 1) return 'Weak';
    if (passwordStrength == 2) return 'Fair';
    if (passwordStrength == 3) return 'Good';
    return 'Strong';
  }

  Color get strengthColor {
    if (passwordStrength <= 1) return Colors.red;
    if (passwordStrength == 2) return Colors.orange;
    if (passwordStrength == 3) return Colors.green;
    return Colors.green;
  }

  Widget passwordStrengthIndicator() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: index < passwordStrength
                        ? strengthColor
                        : const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 125),
        Text(
          strengthLabel,
          style: TextStyle(
            fontSize: 10,
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 32, bottom: 32),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's get your Hisaab started!",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Registration form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // Full Name
                      fieldLabel(Icons.person_outline, 'Full Name'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: nameController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: inputDecoration(
                            hint: 'Enter your full name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Email Address
                      fieldLabel(Icons.mail_outline, 'Email Address'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: inputDecoration(
                            hint: 'Enter your email address',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }

                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password
                      fieldLabel(Icons.lock_outline, 'Password'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: inputDecoration(
                            hint: 'Create a password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please create a password';
                            }

                            if (value.length < 8) {
                              return 'Password must contain at least 8 characters';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Password strength indicator
                      passwordStrengthIndicator(),

                      const SizedBox(height: 18),

                      // Confirm Password
                      fieldLabel(
                        Icons.check_circle_outline,
                        'Confirm Password',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: inputDecoration(
                            hint: 'Re-enter your password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }

                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Currency information banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0ECE9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info,
                              size: 12,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 7),
                            const Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.4,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: 'Currency: '),
                                    TextSpan(
                                      text: '₹ INR (Default)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' • Monthly income is completely optional and can be personalized later.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Terms and conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isTermsAccepted,
                              activeColor: primaryColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (value) {
                                setState(() {
                                  isTermsAccepted = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  'By signing up, you agree to our ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Open Terms of Service.
                                  },
                                  child: const Text(
                                    'Terms of Service',
                                    style: TextStyle(
                                      fontSize: 10,
                                      height: 1.4,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: primaryColor,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ' & ',
                                  style: TextStyle(fontSize: 10, height: 1.4),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Open Privacy Policy.
                                  },
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                      color: primaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: primaryColor,
                                    ),
                                  ),
                                ),
                                const Text(
                                  '. Your financial entries remain private by default.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _isRegistering || !_canRegister
                              ? null
                              : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isRegistering
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Continue with Google
                      SizedBox(
                        width: double.infinity,
                        height: 39,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Google Sign-In.
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      // Sign In navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 3),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: primaryColor,
                                decorationThickness: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
