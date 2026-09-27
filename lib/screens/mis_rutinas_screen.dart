import 'package:flutter/material.dart';
import 'create_routine_screen.dart';
import '../db/database_helper.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';
import 'routine_detail_screen.dart';

class MisRutinasScreen extends StatefulWidget {
  const MisRutinasScreen({super.key});

  @override
  State<MisRutinasScreen> createState() => _MisRutinasScreenState();
}

class _MisRutinasScreenState extends State<MisRutinasScreen> {
  int? _usuarioId;
  bool _cargandoSesion = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioId();
  }

  Future<void> _cargarUsuarioId() async {
    final usuarioId = await SessionManager.obtenerUsuarioId();
    setState(() {
      _usuarioId = usuarioId;
      _cargandoSesion = false;
    });
  }

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
    if (_cargandoSesion) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis rutinas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_usuarioId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis rutinas')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Inicia sesión para ver tus rutinas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) => _cargarUsuarioId());
                  },
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis rutinas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().obtenerRutinas(_usuarioId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rutinas = snapshot.data ?? [];

          return ListView(
            children: [
              if (rutinas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Aquí van a aparecer tus rutinas',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                ...rutinas.map((rutina) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoutineDetailScreen(rutina: rutina),
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
                          onPressed: () =>
                              _confirmarEliminar(rutina['id'] as int),
                        ),
                      ],
                    ),
                  );
                }),
            ],
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
