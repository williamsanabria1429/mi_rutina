import 'package:flutter/material.dart';
import 'add_exercise_screen.dart';
import 'imagen_ejercicio_fullscreen_screen.dart';
import 'training_mode_screen.dart';
import '../db/database_helper.dart';
import '../utils/imagen_ejercicio_helper.dart';
import '../widgets/primary_button.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> rutina;

  const RoutineDetailScreen({super.key, required this.rutina});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final Map<int, String?> _imagenesPorEjercicio = {};

  Future<List<Map<String, dynamic>>> _cargarEjercicios() async {
    final ejercicios = await DatabaseHelper().obtenerEjercicios(widget.rutina['id']);
    for (final ejercicio in ejercicios) {
      _imagenesPorEjercicio[ejercicio['id'] as int] =
          await obtenerRutaImagenEjercicio(ejercicio['nombre']?.toString() ?? '');
    }
    return ejercicios;
  }

  void _abrirImagen(BuildContext context, Map<String, dynamic> ejercicio) {
    final rutaImagen = _imagenesPorEjercicio[ejercicio['id']];
    if (rutaImagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este ejercicio no tiene imagen')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagenEjercicioFullscreenScreen(
          nombreEjercicio: ejercicio['nombre']?.toString() ?? '',
          rutaImagen: rutaImagen,
          heroTag: 'mi_ejercicio_${ejercicio['id']}',
        ),
      ),
    );
  }

  Widget _miniatura(Map<String, dynamic> ejercicio) {
    final rutaImagen = _imagenesPorEjercicio[ejercicio['id']];
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: rutaImagen != null
          ? Hero(
              tag: 'mi_ejercicio_${ejercicio['id']}',
              child: Image.asset(
                rutaImagen,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 168,
              ),
            )
          : const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.image_not_supported_outlined),
            ),
    );
  }
  Future<void> _iniciarEntrenamiento(BuildContext context) async {
    final ejercicios = await DatabaseHelper().obtenerEjercicios(widget.rutina['id']);
    if (!context.mounted) return;

    if (ejercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ejercicio antes de iniciar.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingModeScreen(
          rutina: widget.rutina,
          ejercicios: ejercicios,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rutina['nombre'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rutina['nombre'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${widget.rutina['tipoEntrenamiento'] ?? ''}'),
            Text('Objetivo: ${widget.rutina['objetivo'] ?? ''}'),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Iniciar entrenamiento',
              onPressed: () => _iniciarEntrenamiento(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ejercicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _cargarEjercicios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final ejercicios = snapshot.data ?? [];
                  if (ejercicios.isEmpty) {
                    return const Text('Todavía no hay ejercicios agregados.');
                  }
                  return ListView.builder(
                    itemCount: ejercicios.length,
                    itemBuilder: (context, index) {
                      final ejercicio = ejercicios[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _abrirImagen(context, ejercicio),
                          leading: _miniatura(ejercicio),
                          title: Text(ejercicio['nombre'] ?? ''),
                          subtitle: Text(
                            '${ejercicio['series']} series x ${ejercicio['repeticiones']} reps · ${ejercicio['peso']} kg\n${ejercicio['notas'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExerciseScreen(
                                        rutinaId: widget.rutina['id'],
                                        ejercicioExistente: ejercicio,
                                        ejercicioId: ejercicio['id'],
                                      ),
                                    ),
                                  );
                                  setState(() {}); // refresca la lista al volver
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar ejercicio'),
                                      content: Text(
                                        '¿Seguro que quieres eliminar "${ejercicio['nombre']}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmar == true) {
                                    await DatabaseHelper().eliminarEjercicio(ejercicio['id']);
                                    setState(() {}); // refresca la lista al volver
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExerciseScreen(rutinaId: widget.rutina['id']),
            ),
          );
          setState(() {}); // refresca la pantalla al volver
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}