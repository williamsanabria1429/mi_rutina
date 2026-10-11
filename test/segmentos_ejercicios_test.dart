import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mi_rutina/data/segmentos_ejercicios.dart';
import 'package:mi_rutina/utils/imagen_ejercicio_helper.dart';

/// Nombres de ejercicio tal como los arma la app: nombre del archivo sin
/// número inicial ni extensión.
List<String> _nombresDeFotos() {
  const carpetas = [
    'assets/ejercicios_gimnasio',
    'assets/ejercicios_casa_parque',
  ];

  return [
    for (final carpeta in carpetas)
      for (final archivo in Directory(carpeta).listSync().whereType<File>())
        archivo.uri.pathSegments.last
            .replaceFirst(RegExp(r'\.[^.]+$'), '')
            .replaceFirst(RegExp(r'^\d+\s*'), '')
            .trim(),
  ];
}

void main() {
  final nombres = _nombresDeFotos();

  test('Hay 145 fotos de ejercicios', () {
    expect(nombres.length, 145);
  });

  test('Ninguna foto cae en "Otros"', () {
    final sinSegmento = nombres
        .where((n) => obtenerSegmentoEjercicio(n) == segmentoOtros)
        .toList();
    expect(sinSegmento, isEmpty);
  });

  test('Todos los segmentos del mapa están en segmentosMusculares', () {
    final desconocidos = segmentoPorEjercicio.values
        .where((s) => !segmentosMusculares.contains(s))
        .toSet();
    expect(desconocidos, isEmpty);
  });

  test('Cada clave del mapa corresponde a una foto real', () {
    final sobrantes = segmentoPorEjercicio.keys
        .where((clave) => !nombres.contains(clave))
        .toList();
    expect(sobrantes, isEmpty);
  });

  test('El mapa tiene exactamente una clave por foto', () {
    expect(segmentoPorEjercicio.length, nombres.length);
  });
}
