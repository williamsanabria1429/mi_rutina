import 'package:flutter/services.dart';

const List<String> _carpetasEjercicios = [
  'assets/ejercicios_gimnasio/',
  'assets/ejercicios_casa_parque/',
];

String _normalizar(String texto) {
  const conTilde = 'áéíóúÁÉÍÓÚñÑüÜ';
  const sinTilde = 'aeiouAEIOUnNuU';

  var resultado = texto;
  for (var i = 0; i < conTilde.length; i++) {
    resultado = resultado.replaceAll(conTilde[i], sinTilde[i]);
  }

  return resultado.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _quitarNumeroInicial(String nombreArchivoSinExtension) {
  return nombreArchivoSinExtension
      .replaceFirst(RegExp(r'^\d+\s*'), '')
      .trim();
}

List<String>? _manifestCache;
Future<List<String>>? _manifestCargando;

Future<List<String>> _obtenerManifest() async {
  if (_manifestCache != null) {
    return _manifestCache!;
  }

  _manifestCargando ??= AssetManifest.loadFromAssetBundle(rootBundle).then((
    manifest,
  ) {
    final assets = manifest
        .listAssets()
        .where(
          (ruta) => _carpetasEjercicios.any((carpeta) => ruta.startsWith(carpeta)),
        )
        .toList();
    _manifestCache = assets;
    return assets;
  });

  return _manifestCargando!;
}

Future<String?> obtenerRutaImagenEjercicio(String nombreEjercicio) async {
  final assets = await _obtenerManifest();

  final nombreBuscado = _normalizar(nombreEjercicio);

  for (final rutaAsset in assets) {
    final nombreArchivo = rutaAsset.substring(rutaAsset.lastIndexOf('/') + 1);
    final puntoExtension = nombreArchivo.lastIndexOf('.');
    final nombreSinExtension = puntoExtension == -1
        ? nombreArchivo
        : nombreArchivo.substring(0, puntoExtension);

    final nombreSinNumero = _quitarNumeroInicial(nombreSinExtension);

    if (_normalizar(nombreSinNumero) == nombreBuscado) {
      return rutaAsset;
    }
  }

  return null;
}
