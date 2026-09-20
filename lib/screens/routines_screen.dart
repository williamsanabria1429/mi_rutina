import 'package:flutter/material.dart';
import 'create_routine_screen.dart';
import '../db/database_helper.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'routine_detail_screen.dart';
import 'rutinas_preestablecidas_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
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
        appBar: AppBar(title: const Text('Entrenamiento')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_usuarioId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Entrenamiento')),
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
        title: const Text('Entrenamiento'),
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
              _buildSeccionRutinasPreestablecidas(context),
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

  Widget _buildSeccionRutinasPreestablecidas(BuildContext context) {
    const categorias = [
      {'nombre': 'Casa', 'icono': Icons.home},
      {'nombre': 'Gimnasio', 'icono': Icons.fitness_center},
      {'nombre': 'Parque', 'icono': Icons.park},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rutinas preestablecidas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...categorias.map((categoria) {
            final nombre = categoria['nombre'] as String;
            final icono = categoria['icono'] as IconData;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RutinasPreestablecidasScreen(categoria: nombre),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(icono, color: AppColors.accent, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '20 rutinas',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}