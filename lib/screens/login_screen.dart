import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Placeholder: aquí irá el formulario de inicio de sesión
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Aquí irá el formulario de inicio de sesión'),
      ),
    );
  }
}
