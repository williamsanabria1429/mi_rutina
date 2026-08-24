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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          primary: AppColors.accent,
          secondary: AppColors.secondaryButton,
          surface: AppColors.card,
        ),
        cardColor: AppColors.card,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondaryButton,
            side: const BorderSide(color: AppColors.secondaryButton, width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        fontFamily: 'Roboto', // Cambia a 'Inter' o 'Montserrat' si las agregas como fuentes personalizadas
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
