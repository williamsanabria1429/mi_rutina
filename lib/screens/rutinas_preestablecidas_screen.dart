import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/imagen_ejercicio_helper.dart';
import 'detalle_rutina_preestablecida_screen.dart';

class RutinasPreestablecidasScreen extends StatefulWidget {
  final String categoria;

  const RutinasPreestablecidasScreen({super.key, required this.categoria});

  @override
  State<RutinasPreestablecidasScreen> createState() =>
      _RutinasPreestablecidasScreenState();
}

class _RutinasPreestablecidasScreenState
    extends State<RutinasPreestablecidasScreen> {
  List<Map<String, dynamic>> _rutinas = [];
  final Map<int, String?> _imagenesPorRutina = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }

  Future<void> _cargarRutinas() async {
    List<Map<String, dynamic>> rutinas = [];
    try {
      final dbHelper = DatabaseHelper();
      rutinas = await dbHelper.obtenerRutinasPreestablecidasPorCategoria(
        widget.categoria,
      );

      if (widget.categoria == 'Gimnasio') {
        for (final rutina in rutinas) {
          final rutinaId = rutina['id'] as int;
          final ejercicios = await dbHelper
              .obtenerEjerciciosDeRutinaPreestablecida(rutinaId);
          if (ejercicios.isNotEmpty) {
            final nombreEjercicio = ejercicios.first['nombre'] as String;
            try {
              _imagenesPorRutina[rutinaId] =
                  await obtenerRutaImagenEjercicio(nombreEjercicio);
            } catch (e) {
              print('Error cargando imagen de ejercicio: $e');
              _imagenesPorRutina[rutinaId] = null;
            }
          } else {
            _imagenesPorRutina[rutinaId] = null;
          }
        }
      }
    } finally {
      setState(() {
        _rutinas = rutinas;
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
        title: Text('Rutinas de ${widget.categoria}'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rutinas.length,
              itemBuilder: (context, index) {
                final rutina = _rutinas[index];
                final rutinaId = rutina['id'] as int;
                final rutaImagen = _imagenesPorRutina[rutinaId];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRutinaPreestablecidaScreen(
                            rutinaId: rutinaId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: rutaImagen != null
                                ? Image.asset(
                                    rutaImagen,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: AppColors.accent,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rutina['nombre'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${rutina['nivel']} · ${rutina['objetivo']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
