import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AddExerciseScreen extends StatefulWidget {
  final int rutinaId;
  final Map<String, dynamic>? ejercicioExistente;
  final int? ejercicioId;

  const AddExerciseScreen({
    super.key,
    required this.rutinaId,
    this.ejercicioExistente,
    this.ejercicioId,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _seriesController = TextEditingController();
  final _repeticionesController = TextEditingController();
  final _pesoController = TextEditingController();
  final _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final datos = widget.ejercicioExistente;
    if (datos != null) {
      _nombreController.text = datos['nombre']?.toString() ?? '';
      _seriesController.text = datos['series']?.toString() ?? '';
      _repeticionesController.text = datos['repeticiones']?.toString() ?? '';
      _pesoController.text = datos['peso']?.toString() ?? '';
      _notasController.text = datos['notas']?.toString() ?? '';
    }
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final datosEjercicio = {
        'rutinaId': widget.rutinaId,
        'nombre': _nombreController.text,
        'series': int.parse(_seriesController.text),
        'repeticiones': int.parse(_repeticionesController.text),
        'peso': double.parse(_pesoController.text.isEmpty ? '0' : _pesoController.text),
        'notas': _notasController.text,
      };

      if (widget.ejercicioId != null) {
        await DatabaseHelper().actualizarEjercicio(widget.ejercicioId!, datosEjercicio);
      } else {
        await DatabaseHelper().guardarEjercicio(widget.rutinaId, datosEjercicio);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.ejercicioId != null;
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar ejercicio' : 'Nuevo ejercicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del ejercicio'),
                validator: (v) => (v == null || v.isEmpty) ? 'Ingresa un nombre' : null,
              ),
              TextFormField(
                controller: _seriesController,
                decoration: const InputDecoration(labelText: 'Series'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Ingresa las series' : null,
              ),
              TextFormField(
                controller: _repeticionesController,
                decoration: const InputDecoration(labelText: 'Repeticiones'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Ingresa las repeticiones' : null,
              ),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: Text(esEdicion ? 'Guardar cambios' : 'Guardar ejercicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}