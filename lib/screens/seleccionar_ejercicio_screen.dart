import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/imagen_ejercicio_helper.dart';

/// Lista de todos los ejercicios con foto. Devuelve (Navigator.pop) el nombre
/// del ejercicio escogido, o el nombre escrito a mano.
class SeleccionarEjercicioScreen extends StatefulWidget {
  const SeleccionarEjercicioScreen({super.key});

  @override
  State<SeleccionarEjercicioScreen> createState() =>
      _SeleccionarEjercicioScreenState();
}

class _SeleccionarEjercicioScreenState
    extends State<SeleccionarEjercicioScreen> {
  List<EjercicioConImagen> _ejercicios = [];
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    final ejercicios = await obtenerListaEjercicios();
    if (!mounted) return;
    setState(() {
      _ejercicios = ejercicios;
      _cargando = false;
    });
  }

  Future<void> _escribirOtroEjercicio() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEscribirEjercicio(textoInicial: _busqueda.trim()),
    );

    if (nombre != null && nombre.isNotEmpty && mounted) {
      Navigator.pop(context, nombre);
    }
  }

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _itemEjercicio(EjercicioConImagen ejercicio) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            ejercicio.rutaImagen,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            cacheWidth: 168,
          ),
        ),
        title: Text(
          ejercicio.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () => Navigator.pop(context, ejercicio.nombre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados =
        _ejercicios.where((e) => e.coincideCon(_busqueda)).toList();
    final gimnasio = filtrados.where((e) => e.esGimnasio).toList();
    final casaParque = filtrados.where((e) => !e.esGimnasio).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Escoger ejercicio'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar ejercicio',
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textLight,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _busqueda = v),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (gimnasio.isNotEmpty) ...[
                        _tituloSeccion('Gimnasio'),
                        ...gimnasio.map(_itemEjercicio),
                      ],
                      if (casaParque.isNotEmpty) ...[
                        _tituloSeccion('Casa / Parque'),
                        ...casaParque.map(_itemEjercicio),
                      ],
                      if (filtrados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No se encontraron ejercicios',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      Card(
                        color: AppColors.card,
                        margin: const EdgeInsets.only(top: 8, bottom: 24),
                        child: ListTile(
                          leading: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.edit, color: AppColors.accent),
                          ),
                          title: const Text(
                            'Escribir otro ejercicio…',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: _escribirOtroEjercicio,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Diálogo con su propio controller: se destruye en dispose(), cuando el
/// diálogo ya terminó de cerrarse, y no mientras aún se está animando.
class _DialogoEscribirEjercicio extends StatefulWidget {
  final String textoInicial;

  const _DialogoEscribirEjercicio({required this.textoInicial});

  @override
  State<_DialogoEscribirEjercicio> createState() =>
      _DialogoEscribirEjercicioState();
}

class _DialogoEscribirEjercicioState extends State<_DialogoEscribirEjercicio> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.textoInicial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escribir otro ejercicio'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Nombre del ejercicio'),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
