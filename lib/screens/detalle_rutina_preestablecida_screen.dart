import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/imagen_ejercicio_helper.dart';
import 'imagen_ejercicio_fullscreen_screen.dart';

class DetalleRutinaPreestablecidaScreen extends StatefulWidget {
  final int rutinaId;

  const DetalleRutinaPreestablecidaScreen({super.key, required this.rutinaId});

  @override
  State<DetalleRutinaPreestablecidaScreen> createState() =>
      _DetalleRutinaPreestablecidaScreenState();
}

class _DetalleRutinaPreestablecidaScreenState
    extends State<DetalleRutinaPreestablecidaScreen> {
  List<Map<String, dynamic>> _ejercicios = [];
  final Map<int, String?> _imagenesPorEjercicio = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    List<Map<String, dynamic>> ejercicios = [];
    try {
      ejercicios = await DatabaseHelper()
          .obtenerEjerciciosDeRutinaPreestablecida(widget.rutinaId);

      for (final ejercicio in ejercicios) {
        final ejercicioId = ejercicio['id'] as int;
        final nombre = ejercicio['nombre'] as String;
        try {
          _imagenesPorEjercicio[ejercicioId] =
              await obtenerRutaImagenEjercicio(nombre);
        } catch (e) {
          print('Error cargando imagen de ejercicio: $e');
          _imagenesPorEjercicio[ejercicioId] = null;
        }
      }
    } finally {
      setState(() {
        _ejercicios = ejercicios;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Detalle de la rutina'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ejercicios.length,
              itemBuilder: (context, index) {
                final ejercicio = _ejercicios[index];
                final ejercicioId = ejercicio['id'] as int;
                final rutaImagen = _imagenesPorEjercicio[ejercicioId];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: rutaImagen == null
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ImagenEjercicioFullscreenScreen(
                                          nombreEjercicio:
                                              ejercicio['nombre'] as String,
                                          rutaImagen: rutaImagen,
                                          heroTag: 'imagen_ejercicio_$ejercicioId',
                                        ),
                                  ),
                                ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: rutaImagen != null
                                ? Hero(
                                    tag: 'imagen_ejercicio_$ejercicioId',
                                    child: Image.asset(
                                      rutaImagen,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: AppColors.accent,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ejercicio['nombre'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ejercicio['series']} series · ${ejercicio['repeticiones']} repeticiones · '
                                '${ejercicio['descanso_segundos']}s descanso',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
