import 'package:flutter/material.dart';
import '../models/rutina.dart';
import '../db/database_helper.dart';
import '../services/session_manager.dart';

class CreateRoutineScreen extends StatefulWidget {
  final Map<String, dynamic>? rutinaExistente;
  final int? rutinaId;

  const CreateRoutineScreen({super.key, this.rutinaExistente, this.rutinaId});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  String _tipoEntrenamiento = 'Gimnasio';
  String _objetivo = 'Fuerza';

  final List<String> _tipos = ['Gimnasio', 'Casa', 'Calistenia'];
  final List<String> _objetivos = [
    'Fuerza',
    'Hipertrofia',
    'Pérdida de grasa',
    'Resistencia',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.rutinaExistente != null) {
      final r = widget.rutinaExistente!;
      _nombreController.text = r['nombre'] ?? '';
      _tipoEntrenamiento = r['tipoEntrenamiento'] ?? 'Gimnasio';
      _objetivo = r['objetivo'] ?? 'Fuerza';
    }
  }

  Future<void> _guardarRutina() async {
    if (_formKey.currentState!.validate()) {
      final usuarioId = await SessionManager.obtenerUsuarioId();
      if (usuarioId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicia sesión para guardar una rutina')),
        );
        return;
      }

      final rutina = Rutina(
        nombre: _nombreController.text,
        descripcion: '',
        tipoEntrenamiento: _tipoEntrenamiento,
        subcategoria: '',
        objetivo: _objetivo,
        zonaCorporal: '',
        nivel: '',
        duracion: '',
        metodo: '',
        favorita: false,
        fechaCreacion: DateTime.now().toIso8601String(),
        usuarioId: usuarioId,
      );

      if (widget.rutinaId != null) {
        await DatabaseHelper().actualizarRutina(widget.rutinaId!, rutina);
      } else {
        await DatabaseHelper().guardarRutina(rutina);
      }

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rutinaId != null ? 'Editar rutina' : 'Nueva rutina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoEntrenamiento,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _tipos
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoEntrenamiento = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _objetivo,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                items: _objetivos
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _objetivo = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarRutina,
                child: Text(widget.rutinaId != null ? 'Guardar cambios' : 'Guardar rutina'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}