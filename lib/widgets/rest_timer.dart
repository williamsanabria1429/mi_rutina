import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

const MethodChannel _vibrationChannel = MethodChannel('mi_rutina/vibration');

/// Cronómetro de descanso entre series.
/// Muestra 3 duraciones para elegir y luego una cuenta regresiva circular.
/// Llama a [onFinished] cuando el descanso termina o se salta.
class RestTimer extends StatefulWidget {
  final VoidCallback onFinished;

  const RestTimer({super.key, required this.onFinished});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  static const List<int> _opciones = [30, 60, 90];

  int? _totalSegundos;
  int _restantes = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciar(int segundos) {
    setState(() {
      _totalSegundos = segundos;
      _restantes = segundos;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_restantes <= 1) {
      _finalizar();
      return;
    }
    setState(() => _restantes--);
  }

  void _ajustar(int delta) {
    setState(() {
      _restantes = (_restantes + delta).clamp(0, 3600);
      if (_restantes > (_totalSegundos ?? 0)) {
        _totalSegundos = _restantes;
      }
    });
    if (_restantes <= 0) _finalizar();
  }

  void _finalizar() {
    _timer?.cancel();
    _timer = null;
    _avisarFinDescanso();
    widget.onFinished();
  }

  // HapticFeedback/SystemSound quedan silenciosos si el usuario desactivó
  // "Vibración táctil" o "Sonidos táctiles" en Android. El canal nativo
  // llama directo al Vibrator del sistema, sin depender de esos ajustes.
  static Future<void> _avisarFinDescanso() async {
    try {
      await _vibrationChannel.invokeMethod('vibrate', {'duration': 400});
    } on MissingPluginException {
      HapticFeedback.mediumImpact();
    }
    final player = AudioPlayer();
    unawaited(
      player.onPlayerComplete.first.then((_) => player.dispose()),
    );
    await player.play(AssetSource('sounds/alert.wav'));
  }

  void _saltar() {
    _timer?.cancel();
    _timer = null;
    widget.onFinished();
  }

  String _formatear(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: _totalSegundos == null ? _buildSelector() : _buildCuentaRegresiva(),
      ),
    );
  }

  Widget _buildSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Descanso',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _opciones
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () => _iniciar(s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('${s}s', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCuentaRegresiva() {
    final total = _totalSegundos!;
    final progreso = total == 0 ? 0.0 : _restantes / total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  value: progreso,
                  strokeWidth: 10,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Text(
                _formatear(_restantes),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => _ajustar(-15),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryButton,
                side: const BorderSide(color: AppColors.secondaryButton),
              ),
              child: const Text('-15s'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _ajustar(15),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryButton,
                side: const BorderSide(color: AppColors.secondaryButton),
              ),
              child: const Text('+15s'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _saltar,
          child: const Text(
            'Saltar descanso',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
