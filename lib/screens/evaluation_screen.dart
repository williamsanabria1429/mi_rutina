import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Placeholder: aquí irá el flujo de evaluación inicial
/// (nivel del usuario, objetivo, etc.)
class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Evaluación Inicial'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Aquí irá el formulario de evaluación inicial'),
      ),
    );
  }
}
