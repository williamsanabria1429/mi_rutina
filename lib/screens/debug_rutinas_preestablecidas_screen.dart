import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class DebugRutinasPreestablecidasScreen extends StatefulWidget {
  const DebugRutinasPreestablecidasScreen({super.key});

  @override
  State<DebugRutinasPreestablecidasScreen> createState() =>
      _DebugRutinasPreestablecidasScreenState();
}

class _DebugRutinasPreestablecidasScreenState
    extends State<DebugRutinasPreestablecidasScreen> {
  static const categorias = ['Casa', 'Gimnasio', 'Parque'];

  final Map<String, List<Map<String, dynamic>>> _rutinasPorCategoria = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }

  Future<void> _cargarRutinas() async {
    final dbHelper = DatabaseHelper();
    final resultados = <String, List<Map<String, dynamic>>>{};
    for (final categoria in categorias) {
      resultados[categoria] =
          await dbHelper.obtenerRutinasPreestablecidasPorCategoria(categoria);
    }
    setState(() {
      _rutinasPorCategoria
        ..clear()
        ..addAll(resultados);
      _cargando = false;
    });
  }

  void _abrirEjercicios(Map<String, dynamic> rutina) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DebugEjerciciosScreen(rutina: rutina),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Rutinas preestablecidas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: categorias.map((categoria) {
                      final total = _rutinasPorCategoria[categoria]?.length ?? 0;
                      return Text(
                        '$categoria: $total rutinas',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    children: [
                      for (final categoria in categorias) ...[
                        Container(
                          width: double.infinity,
                          color: Colors.black12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            categoria,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        for (final rutina in _rutinasPorCategoria[categoria] ?? [])
                          ListTile(
                            title: Text(rutina['nombre'] as String),
                            subtitle: Text(
                              'nivel: ${rutina['nivel']} · objetivo: ${rutina['objetivo']}',
                            ),
                            onTap: () => _abrirEjercicios(rutina),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DebugEjerciciosScreen extends StatefulWidget {
  final Map<String, dynamic> rutina;

  const _DebugEjerciciosScreen({required this.rutina});

  @override
  State<_DebugEjerciciosScreen> createState() =>
      _DebugEjerciciosScreenState();
}

class _DebugEjerciciosScreenState extends State<_DebugEjerciciosScreen> {
  List<Map<String, dynamic>> _ejercicios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    final dbHelper = DatabaseHelper();
    final ejercicios = await dbHelper.obtenerEjerciciosDeRutinaPreestablecida(
      widget.rutina['id'] as int,
    );
    setState(() {
      _ejercicios = ejercicios;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.rutina['nombre'] as String)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ejercicios.length,
              itemBuilder: (context, index) {
                final ejercicio = _ejercicios[index];
                return ListTile(
                  title: Text(ejercicio['nombre'] as String),
                  subtitle: Text(
                    'series: ${ejercicio['series']} · repeticiones: ${ejercicio['repeticiones']} · '
                    'descanso: ${ejercicio['descanso_segundos']}s',
                  ),
                );
              },
            ),
    );
  }
}
