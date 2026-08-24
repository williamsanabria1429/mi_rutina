class Ejercicio {
  final int? id;
  final int rutinaId;
  final String nombre;
  final int series;
  final int repeticiones;
  final double peso;
  final String notas;

  Ejercicio({
    this.id,
    required this.rutinaId,
    required this.nombre,
    required this.series,
    required this.repeticiones,
    required this.peso,
    required this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rutinaId': rutinaId,
      'nombre': nombre,
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
      'notas': notas,
    };
  }

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      id: map['id'] as int?,
      rutinaId: map['rutinaId'] as int,
      nombre: map['nombre'] as String,
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int,
      peso: (map['peso'] as num).toDouble(),
      notas: map['notas'] as String,
    );
  }
}