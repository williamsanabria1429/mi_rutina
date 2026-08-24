import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/rest_timer.dart';

/// Modo entrenamiento: guía al usuario ejercicio por ejercicio con
/// descansos cronometrados entre series.
class TrainingModeScreen extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final List<Map<String, dynamic>> ejercicios;

  const TrainingModeScreen({
    super.key,
    required this.rutina,
    required this.ejercicios,
  });

  @override
  State<TrainingModeScreen> createState() => _TrainingModeScreenState();
}

class _TrainingModeScreenState extends State<TrainingModeScreen> {
  int _indiceActual = 0;
  bool _descansando = false;
  bool _completado = false;

  Map<String, dynamic> get _ejercicioActual => widget.ejercicios[_indiceActual];
  bool get _esUltimo => _indiceActual >= widget.ejercicios.length - 1;

  void _completarSerie() {
    setState(() => _descansando = true);
  }

  void _finalizarDescanso() {
    setState(() => _descansando = false);
  }

  void _siguienteEjercicio() {
    if (_esUltimo) {
      setState(() => _completado = true);
    } else {
      setState(() {
        _indiceActual++;
        _descansando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completado) {
      return _buildCompletado();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.rutina['nombre'] ?? 'Entrenamiento'),
      ),
      body: _descansando
          ? RestTimer(onFinished: _finalizarDescanso)
          : _buildEjercicio(),
    );
  }

  Widget _buildEjercicio() {
    final ejercicio = _ejercicioActual;
    final notas = (ejercicio['notas'] ?? '').toString();
    final peso = ejercicio['peso'];
    final tieneSeries = ejercicio['series'] != null && ejercicio['repeticiones'] != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ejercicio ${_indiceActual + 1} de ${widget.ejercicios.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const Spacer(),
            Text(
              ejercicio['nombre'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (tieneSeries) ...[
              const SizedBox(height: 16),
              Text(
                '${ejercicio['series']} series x ${ejercicio['repeticiones']} reps'
                '${peso != null && peso != 0 ? ' · $peso kg' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
            ],
            if (notas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                notas,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const Spacer(),
            PrimaryButton(text: 'Completar serie', onPressed: _completarSerie),
            const SizedBox(height: 12),
            SecondaryButton(
              text: _esUltimo ? 'Finalizar entrenamiento' : 'Siguiente ejercicio',
              onPressed: _siguienteEjercicio,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletado() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.accent, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Entrenamiento completado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¡Buen trabajo con "${widget.rutina['nombre'] ?? ''}"!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, fontSize: 15),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Volver a Inicio',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
