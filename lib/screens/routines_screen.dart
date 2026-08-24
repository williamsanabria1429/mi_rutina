import 'package:flutter/material.dart';
import 'create_routine_screen.dart';
import '../db/database_helper.dart';
import 'routine_detail_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  Future<void> _confirmarEliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: const Text('¿Seguro que quieres eliminar esta rutina?'),
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
      await DatabaseHelper().eliminarRutina(id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamiento'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().obtenerRutinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rutinas = snapshot.data ?? [];

          if (rutinas.isEmpty) {
            return const Center(
              child: Text(
                'Aquí van a aparecer tus rutinas',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              final rutina = rutinas[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineDetailScreen(rutina: rutina),
                    ),
                  );
                },
                title: Text(rutina['nombre'] ?? ''),
                subtitle: Text(
                  '${rutina['tipoEntrenamiento'] ?? ''} · ${rutina['objetivo'] ?? ''}',
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
                            builder: (context) => CreateRoutineScreen(
                              rutinaExistente: rutina,
                              rutinaId: rutina['id'] as int?,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarEliminar(rutina['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRoutineScreen(),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}