import 'package:flutter/material.dart';
import 'screens/user/login.dart';
import 'app_colors.dart';

/// Entry point — wires together all 4 screens with a bottom navigation bar.
void main() => runApp(const CivicRoadApp());

class CivicRoadApp extends StatelessWidget {
  const CivicRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicRoad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Inter', // add Inter to pubspec.yaml fonts section
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoginScreen(),
    );
  }
}
