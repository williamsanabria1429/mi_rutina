import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MiRutinaApp());
}

class MiRutinaApp extends StatelessWidget {
  const MiRutinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Rutina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Roboto', // Cambia a 'Inter' o 'Montserrat' si las agregas como fuentes personalizadas
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
