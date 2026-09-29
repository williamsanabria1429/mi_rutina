import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/imagen_ejercicio_helper.dart';
import 'imagen_ejercicio_fullscreen_screen.dart';
import 'seleccionar_ejercicio_screen.dart';

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
  String? _nombreEjercicio;
  String? _rutaImagen;
  final _seriesController = TextEditingController();
  final _repeticionesController = TextEditingController();
  final _pesoController = TextEditingController();
  final _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final datos = widget.ejercicioExistente;
    if (datos != null) {
      final nombre = datos['nombre']?.toString() ?? '';
      if (nombre.isNotEmpty) {
        _nombreEjercicio = nombre;
        _cargarImagen(nombre);
      }
      _seriesController.text = datos['series']?.toString() ?? '';
      _repeticionesController.text = datos['repeticiones']?.toString() ?? '';
      _pesoController.text = datos['peso']?.toString() ?? '';
      _notasController.text = datos['notas']?.toString() ?? '';
    }
  }

  Future<void> _cargarImagen(String nombre) async {
    final ruta = await obtenerRutaImagenEjercicio(nombre);
    if (!mounted || nombre != _nombreEjercicio) return;
    setState(() => _rutaImagen = ruta);
  }

  Future<void> _escogerEjercicio(FormFieldState<String> field) async {
    final nombre = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SeleccionarEjercicioScreen()),
    );
    if (nombre == null || !mounted) return;

    setState(() {
      _nombreEjercicio = nombre;
      _rutaImagen = null;
    });
    field.didChange(nombre);
    field.validate();
    _cargarImagen(nombre);
  }

  void _ampliarImagen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagenEjercicioFullscreenScreen(
          nombreEjercicio: _nombreEjercicio!,
          rutaImagen: _rutaImagen!,
          heroTag: 'imagen_ejercicio_seleccionado',
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final datosEjercicio = {
        'rutinaId': widget.rutinaId,
        'nombre': _nombreEjercicio,
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
              FormField<String>(
                initialValue: _nombreEjercicio,
                validator: (v) => (v == null || v.isEmpty) ? 'Escoge un ejercicio' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _escogerEjercicio(field),
                      icon: const Icon(Icons.list),
                      label: const Text('Escoger ejercicio'),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_nombreEjercicio != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _nombreEjercicio!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (_rutaImagen != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _ampliarImagen,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: 'imagen_ejercicio_seleccionado',
                            child: Image.asset(
                              _rutaImagen!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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