class Rutina {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String tipoEntrenamiento; // Gimnasio, Casa, Parque
  final String? subcategoria; // ej: Peso libre, Máquinas (para más adelante)
  final String? objetivo; // ej: Fuerza, Hipertrofia, Pérdida de grasa
  final String? zonaCorporal; // ej: Piernas, Espalda (para más adelante)
  final String? nivel; // Principiante, Intermedio, Avanzado
  final String? duracion; // ej: 30 minutos
  final String? metodo; // ej: Circuito, Superseries (para más adelante)
  final bool favorita;
  final String fechaCreacion;
  final int? usuarioId;

  Rutina({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoEntrenamiento,
    this.subcategoria,
    this.objetivo,
    this.zonaCorporal,
    this.nivel,
    this.duracion,
    this.metodo,
    this.favorita = false,
    required this.fechaCreacion,
    this.usuarioId,
  });

  // Convierte una Rutina a un Map, para poder guardarla en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoEntrenamiento': tipoEntrenamiento,
      'subcategoria': subcategoria,
      'objetivo': objetivo,
      'zonaCorporal': zonaCorporal,
      'nivel': nivel,
      'duracion': duracion,
      'metodo': metodo,
      'favorita': favorita ? 1 : 0,
      'fechaCreacion': fechaCreacion,
      'usuarioId': usuarioId,
    };
  }

  // Convierte un Map (leído de SQLite) de vuelta a una Rutina
  factory Rutina.fromMap(Map<String, dynamic> map) {
    return Rutina(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      tipoEntrenamiento: map['tipoEntrenamiento'] as String,
      subcategoria: map['subcategoria'] as String?,
      objetivo: map['objetivo'] as String?,
      zonaCorporal: map['zonaCorporal'] as String?,
      nivel: map['nivel'] as String?,
      duracion: map['duracion'] as String?,
      metodo: map['metodo'] as String?,
      favorita: (map['favorita'] as int) == 1,
      fechaCreacion: map['fechaCreacion'] as String,
      usuarioId: map['usuarioId'] as int?,
    );
  }
}