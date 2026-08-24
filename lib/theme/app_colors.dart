import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la app.
/// Cambiar aquí actualiza el color en toda la app.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF222222);
  static const Color accent = Color(0xFFE42020);
  static const Color secondaryButton = Color(0xFFD9D9D9);

  // Alias mantenidos por compatibilidad con el resto de la app.
  static const Color primary = accent;
  static const Color softGray = card;
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color textLight = Color(0xFFA0A0A0);
}
