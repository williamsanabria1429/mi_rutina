import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'evaluation_screen.dart';
import 'evaluation_result_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'routines_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const _Header(),
                      const SizedBox(height: 32),
                      const _HeroSection(),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'Entrenamiento',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RoutinesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Nueva evaluación',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EvaluationScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SecondaryButton(
                        text: 'Iniciar Sesión',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Crear Cuenta',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Ver mi última evaluación',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EvaluationResultScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      const _Footer(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Header: logo (placeholder) + frase motivadora
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.softGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Entrena mejor. Vive mejor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

/// Hero principal: imagen/silueta + título + subtítulo
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.softGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.self_improvement,
            color: AppColors.primary,
            size: 96,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tu entrenamiento empieza aquí.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Programas personalizados según tu nivel y objetivo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

/// Footer: versión + enlaces a términos y privacidad
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Versión 1.0 — Powered by William Sanabria',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: enlazar a pantalla o URL de Términos
              },
              child: const Text(
                'Términos',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
            const Text('·', style: TextStyle(color: AppColors.textLight)),
            TextButton(
              onPressed: () {
                // TODO: enlazar a pantalla o URL de Privacidad
              },
              child: const Text(
                'Privacidad',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}