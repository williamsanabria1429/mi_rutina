import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../db/database_helper.dart';
import 'evaluation_screen.dart';

class EvaluationResultScreen extends StatelessWidget {
  const EvaluationResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseHelper().obtenerUltimaEvaluacion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Mi última evaluación')),
            body: const Center(
              child: Text('Todavía no has completado ninguna evaluación.'),
            ),
          );
        }

        final evaluacion = snapshot.data!;
        final Map<String, dynamic> valores = _parseDatos(evaluacion);
        final List<String> condiciones = _parseCondiciones(evaluacion);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Mi última evaluación'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationScreen(
                        datosExistentes: valores,
                        evaluacionId: evaluacion['id'] as int?,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SeccionCard(
                titulo: 'Datos personales',
                filas: {
                  'Nombre':
                      '${valores['nombre'] ?? ''} ${valores['apellido'] ?? ''}',
                  'Dirección': valores['direccion'],
                  'Teléfono': valores['telefono'],
                },
              ),
              const SizedBox(height: 16),
              _SeccionCard(
                titulo: 'Ficha médica',
                filas: {
                  'Antecedentes deportivos': valores['antecedentesDeportivos'],
                  'Antecedentes físicos': valores['antecedentesFisicos'],
                  'Antecedentes quirúrgicos':
                      valores['antecedentesQuirurgicos'],
                  'Prescripción médica': valores['prescripcionMedica'],
                  'Observaciones médicas': valores['observacionesMedicas'],
                  'Frecuencia cardíaca en reposo': valores['fcReposo'],
                  'Frecuencia cardíaca máxima': valores['fcMaxima'],
                },
              ),
              if (condiciones.isNotEmpty) ...[
                const SizedBox(height: 16),
                _CondicionesCard(condiciones: condiciones),
              ],
              const SizedBox(height: 16),
              _SeccionCard(
                titulo: 'Antropometría',
                filas: {
                  'Estatura (cm)': valores['estatura'],
                  'Peso (kg)': valores['peso'],
                  'Hombro (cm)': valores['hombro'],
                  'Pecho (cm)': valores['pecho'],
                  'Brazo (cm)': valores['brazo'],
                  'Antebrazo (cm)': valores['antebrazo'],
                  'Cintura (cm)': valores['cintura'],
                  'Cadera (cm)': valores['cadera'],
                  'Muslos (cm)': valores['muslos'],
                  'Pantorrilla (cm)': valores['pantorrilla'],
                  'Grasa (%)': valores['grasaPct'],
                  'Músculo (%)': valores['musculoPct'],
                  'Agua (%)': valores['aguaPct'],
                  'Grasa visceral': valores['grasaVisceral'],
                  'Hueso (kg)': valores['hueso'],
                  'Metabolismo (kcal)': valores['metabolismo'],
                  'Proteína (%)': valores['proteina'],
                  'Edad biológica': valores['edadBiologica'],
                  'Peso magro (kg)': valores['pesoMagro'],
                  'Objetivo final': valores['objetivoFinal'],
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _parseDatos(Map<String, dynamic> evaluacion) {
    final raw = evaluacion['datos'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        return Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  List<String> _parseCondiciones(Map<String, dynamic> evaluacion) {
    final raw = evaluacion['condiciones'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final Map<String, dynamic> filas;

  const _SeccionCard({required this.titulo, required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...filas.entries.map((entry) {
            final valor = entry.value;
            final texto = (valor == null || valor.toString().trim().isEmpty)
                ? '—'
                : valor.toString();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CondicionesCard extends StatelessWidget {
  final List<String> condiciones;

  const _CondicionesCard({required this.condiciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Condiciones médicas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: condiciones.map((c) {
              return Chip(
                label: Text(c),
                backgroundColor: AppColors.background,
                labelStyle: const TextStyle(color: AppColors.textDark),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}