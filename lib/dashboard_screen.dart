import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'database_config.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = user == null
        ? null
        : FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: realtimeDatabaseUrl,
          ).ref('users/${user.uid}');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/common_logo.png',
                    width: 120,
                    height: 48,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: const Color(0xFF494323),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (_) => false,
                      );
                    },
                    child: const CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFE8E3D4),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF494323),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: profile == null
                    ? const _WelcomeText(username: 'there')
                    : StreamBuilder<DatabaseEvent>(
                        stream: profile.onValue,
                        builder: (context, snapshot) {
                          final data = snapshot.data?.snapshot.value;
                          final username = data is Map
                              ? data['name']?.toString()
                              : null;
                          return _WelcomeText(
                            username:
                                username == null || username.trim().isEmpty
                                ? user?.displayName ?? 'there'
                                : username,
                          );
                        },
                      ),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final trimmedName = username.trim();
    final firstName = trimmedName.isEmpty
        ? 'there'
        : trimmedName.split(RegExp(r'\s+')).first;
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 17 => 'Good afternoon',
      >= 17 && < 21 => 'Good evening',
      _ => 'Good night',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$greeting, $firstName!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to check your money?',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF494323),
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}
