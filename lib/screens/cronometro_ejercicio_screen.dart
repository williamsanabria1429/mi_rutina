import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

/// Cronómetro (cuenta hacia arriba) para un ejercicio de rutina preestablecida.
/// Si se indica [descansoRecomendadoSegundos], muestra el descanso recomendado
/// y un anillo que se llena hasta alcanzarlo. El tiempo no se guarda.
class CronometroEjercicioScreen extends StatefulWidget {
  final String nombreEjercicio;
  final int? descansoRecomendadoSegundos;

  const CronometroEjercicioScreen({
    super.key,
    required this.nombreEjercicio,
    this.descansoRecomendadoSegundos,
  });

  @override
  State<CronometroEjercicioScreen> createState() =>
      _CronometroEjercicioScreenState();
}

class _CronometroEjercicioScreenState extends State<CronometroEjercicioScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _detenerYVolver() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    Navigator.pop(context);
  }

  String _formatear(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final transcurridos = _stopwatch.elapsed.inSeconds;
    final descanso = widget.descansoRecomendadoSegundos;
    final tieneDescanso = descanso != null && descanso > 0;
    final superado = tieneDescanso && transcurridos >= descanso;

    final textoTiempo = Text(
      _formatear(transcurridos),
      style: TextStyle(
        color: superado ? AppColors.accent : Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.nombreEjercicio),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tieneDescanso)
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: CircularProgressIndicator(
                                  value: (transcurridos / descanso)
                                      .clamp(0.0, 1.0),
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.accent),
                                ),
                              ),
                              textoTiempo,
                            ],
                          ),
                        )
                      else
                        textoTiempo,
                      if (tieneDescanso) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Descanso recomendado: ${descanso}s',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: 'Detener y volver',
                onPressed: _detenerYVolver,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
