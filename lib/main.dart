import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:hisaabmitra/config/firebase_options.dart';
import 'package:hisaabmitra/screens/dashboard_screen.dart';
import 'package:hisaabmitra/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {'/dashboard': (_) => const DashboardScreen()},
    );
  }
}
