import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/rutina.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mi_rutina.db');
    return await openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE evaluaciones(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT,
            datos TEXT,
            condiciones TEXT
          )
        ''');
        await db.execute('''
      CREATE TABLE rutinas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        descripcion TEXT,
        tipoEntrenamiento TEXT,
        subcategoria TEXT,
        objetivo TEXT,
        zonaCorporal TEXT,
        nivel TEXT,
        duracion TEXT,
        metodo TEXT,
        favorita INTEGER,
        fechaCreacion TEXT,
        usuarioId INTEGER
      )
    ''');
    await db.execute('''
          CREATE TABLE ejercicios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rutinaId INTEGER,
            nombre TEXT,
            series INTEGER,
            repeticiones INTEGER,
            peso REAL,
            notas TEXT
          )
        ''');
    await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE,
            contrasena TEXT NOT NULL,
            genero TEXT NOT NULL,
            pregunta_seguridad TEXT,
            respuesta_seguridad TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE rutinas_preestablecidas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria TEXT NOT NULL,
            nivel TEXT NOT NULL,
            objetivo TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ejercicios_preestablecidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rutina_id INTEGER NOT NULL,
            nombre TEXT NOT NULL,
            series INTEGER NOT NULL,
            repeticiones INTEGER NOT NULL,
            descanso_segundos INTEGER NOT NULL,
            FOREIGN KEY (rutina_id) REFERENCES rutinas_preestablecidas (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS usuarios(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              correo TEXT NOT NULL UNIQUE,
              contrasena TEXT NOT NULL,
              genero TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            ALTER TABLE rutinas ADD COLUMN usuarioId INTEGER
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            ALTER TABLE usuarios ADD COLUMN pregunta_seguridad TEXT
          ''');
          await db.execute('''
            ALTER TABLE usuarios ADD COLUMN respuesta_seguridad TEXT
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS rutinas_preestablecidas(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              categoria TEXT NOT NULL,
              nivel TEXT NOT NULL,
              objetivo TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ejercicios_preestablecidos(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              rutina_id INTEGER NOT NULL,
              nombre TEXT NOT NULL,
              series INTEGER NOT NULL,
              repeticiones INTEGER NOT NULL,
              descanso_segundos INTEGER NOT NULL,
              FOREIGN KEY (rutina_id) REFERENCES rutinas_preestablecidas (id)
            )
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            UPDATE ejercicios_preestablecidos
            SET series = 1, repeticiones = 45, descanso_segundos = 0
            WHERE nombre IN (
              'Cinta de correr', 'Elíptica', 'Bicicleta estática', 'Escaladora', 'Remo'
            )
            AND rutina_id IN (
              SELECT id FROM rutinas_preestablecidas WHERE categoria = 'Gimnasio'
            )
          ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            UPDATE ejercicios_preestablecidos
            SET repeticiones = 60
            WHERE nombre IN ('Plancha', 'Plancha lateral')
            AND rutina_id IN (
              SELECT id FROM rutinas_preestablecidas WHERE categoria IN ('Casa', 'Parque')
            )
          ''');
          await db.execute('''
            UPDATE ejercicios_preestablecidos
            SET repeticiones = 20
            WHERE nombre = 'Plancha bocaabajo'
            AND rutina_id IN (
              SELECT id FROM rutinas_preestablecidas WHERE categoria = 'Gimnasio'
            )
          ''');
        }
      },
    );
  }

  Future<int> guardarEvaluacion(
    Map<String, dynamic> valores,
    Set<String> condiciones,
  ) async {
    final db = await database;
    return await db.insert('evaluaciones', {
      'fecha': DateTime.now().toIso8601String(),
      'datos': jsonEncode(valores),
      'condiciones': jsonEncode(condiciones.toList()),
    });
  }
  Future<int> guardarRutina(Rutina rutina) async {
    final db = await database;
    return await db.insert('rutinas', rutina.toMap());
  }
  Future<int> insertarUsuario(
    String nombre,
    String correo,
    String contrasena,
    String genero, {
    String? preguntaSeguridad,
    String? respuestaSeguridad,
  }) async {
    final db = await database;
    return await db.insert('usuarios', {
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'genero': genero,
      'pregunta_seguridad': preguntaSeguridad,
      'respuesta_seguridad': respuestaSeguridad,
    });
  }
  Future<Map<String, dynamic>?> validarLogin(String correo, String contrasena) async {
    final db = await database;
    final resultados = await db.query(
      'usuarios',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
    );
    if (resultados.isEmpty) return null;
    return resultados.first;
  }
  Future<Map<String, dynamic>?> obtenerUsuarioPorCorreo(String correo) async {
    final db = await database;
    final resultados = await db.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correo],
    );
    if (resultados.isEmpty) return null;
    return resultados.first;
  }
  Future<int> actualizarContrasena(int usuarioId, String nuevaContrasena) async {
    final db = await database;
    return await db.update(
      'usuarios',
      {'contrasena': nuevaContrasena},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }
  Future<void> actualizarEjercicio(int id, Map<String, dynamic> ejercicio) async {
  final db = await database;
  await db.update(
    'ejercicios',
    ejercicio,
    where: 'id = ?',
    whereArgs: [id],
  );
}
Future<void> eliminarEjercicio(int id) async {
  final db = await database;
  await db.delete(
    'ejercicios',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  Future<int> guardarEjercicio(int rutinaId, Map<String, dynamic> ejercicio) async {
  final db = await database;
  return await db.insert('ejercicios', {
    'rutinaId': rutinaId,
    'nombre': ejercicio['nombre'],
    'series': ejercicio['series'],
    'repeticiones': ejercicio['repeticiones'],
    'peso': ejercicio['peso'],
    'notas': ejercicio['notas'],
  });
}

Future<List<Map<String, dynamic>>> obtenerEjercicios(int rutinaId) async {
  final db = await database;
  return await db.query(
    'ejercicios',
    where: 'rutinaId = ?',
    whereArgs: [rutinaId],
  );
}
  Future<List<Map<String, dynamic>>> obtenerRutinas(int usuarioId) async {
  final db = await database;
  return await db.query(
    'rutinas',
    where: 'usuarioId = ?',
    whereArgs: [usuarioId],
    orderBy: 'fechaCreacion DESC',
  );
}
Future<int> actualizarRutina(int id, Rutina rutina) async {
  final db = await database;
  final datos = rutina.toMap()..remove('id');
  return await db.update(
    'rutinas',
    datos,
    where: 'id = ?',
    whereArgs: [id],
  );
}
Future<int> eliminarRutina(int id) async {
  final db = await database;
  return await db.delete(
    'rutinas',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  Future<int> actualizarEvaluacion(
  int id,
  Map<String, dynamic> valores,
  Set<String> condiciones,
) async {
  final db = await database;
  return await db.update(
    'evaluaciones',
    {
      'fecha': DateTime.now().toIso8601String(),
      'datos': jsonEncode(valores),
      'condiciones': jsonEncode(condiciones.toList()),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

  Future<List<Map<String, dynamic>>> obtenerEvaluaciones() async {
    final db = await database;
    return await db.query('evaluaciones', orderBy: 'id DESC');
  }
  Future<Map<String, dynamic>?> obtenerUltimaEvaluacion() async {
    final evaluaciones = await obtenerEvaluaciones();
    if (evaluaciones.isEmpty) return null;
    return evaluaciones.first;
  }

  Future<int> insertarRutinaPreestablecida(
    String nombre,
    String categoria,
    String nivel,
    String objetivo,
  ) async {
    final db = await database;
    return await db.insert('rutinas_preestablecidas', {
      'nombre': nombre,
      'categoria': categoria,
      'nivel': nivel,
      'objetivo': objetivo,
    });
  }

  Future<int> insertarEjercicioPreestablecido(
    int rutinaId,
    String nombre,
    int series,
    int repeticiones,
    int descansoSegundos,
  ) async {
    final db = await database;
    return await db.insert('ejercicios_preestablecidos', {
      'rutina_id': rutinaId,
      'nombre': nombre,
      'series': series,
      'repeticiones': repeticiones,
      'descanso_segundos': descansoSegundos,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerRutinasPreestablecidasPorCategoria(
    String categoria,
  ) async {
    final db = await database;
    return await db.query(
      'rutinas_preestablecidas',
      where: 'categoria = ?',
      whereArgs: [categoria],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerEjerciciosDeRutinaPreestablecida(
    int rutinaId,
  ) async {
    final db = await database;
    return await db.query(
      'ejercicios_preestablecidos',
      where: 'rutina_id = ?',
      whereArgs: [rutinaId],
    );
  }

  Future<void> cargarRutinasPreestablecidasSiVacio() async {
    final db = await database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM rutinas_preestablecidas',
    );
    final total = Sqflite.firstIntValue(resultado) ?? 0;
    if (total != 0) return;

    const rutinas = [
      ['Flexiones de pecho', 'Plancha', 'Sentadillas', 'Jumping jacks'],
      ['Flexiones inclinadas', 'Plancha lateral', 'Zancadas', 'Burpees'],
      ['Flexiones diamante', 'Abdominales', 'Sentadilla búlgara', 'High knees'],
      ['Fondos en silla', 'Elevación de piernas', 'Puente de glúteo', 'Jump squat'],
      ['Superman', 'Mountain climbers', 'Elevación de talones', 'Plancha con toque de hombro'],
      ['Flexiones de pecho', 'Abdominales', 'Zancadas', 'Burpees'],
      ['Flexiones inclinadas', 'Elevación de piernas', 'Sentadilla búlgara', 'High knees'],
      ['Flexiones diamante', 'Mountain climbers', 'Puente de glúteo', 'Jump squat'],
      ['Fondos en silla', 'Plancha', 'Elevación de talones', 'Plancha con toque de hombro'],
      ['Superman', 'Plancha lateral', 'Sentadillas', 'Jumping jacks'],
      ['Flexiones de pecho', 'Mountain climbers', 'Elevación de talones', 'High knees'],
      ['Flexiones inclinadas', 'Plancha', 'Puente de glúteo', 'Jump squat'],
      ['Flexiones diamante', 'Plancha lateral', 'Sentadillas', 'Plancha con toque de hombro'],
      ['Fondos en silla', 'Abdominales', 'Zancadas', 'Jumping jacks'],
      ['Superman', 'Elevación de piernas', 'Sentadilla búlgara', 'Burpees'],
      ['Flexiones de pecho', 'Plancha lateral', 'Puente de glúteo', 'Plancha con toque de hombro'],
      ['Flexiones inclinadas', 'Abdominales', 'Sentadillas', 'Burpees'],
      ['Flexiones diamante', 'Elevación de piernas', 'Zancadas', 'Jump squat'],
      ['Fondos en silla', 'Mountain climbers', 'Sentadilla búlgara', 'Jumping jacks'],
      ['Superman', 'Plancha', 'Elevación de talones', 'High knees'],
    ];

    for (var i = 0; i < rutinas.length; i++) {
      final rutinaId = await insertarRutinaPreestablecida(
        'Rutina ${i + 1}',
        'Casa',
        'Principiante',
        'Resistencia',
      );
      for (final ejercicio in rutinas[i]) {
        final esIsometrico =
            ejercicio == 'Plancha' || ejercicio == 'Plancha lateral';
        await insertarEjercicioPreestablecido(
          rutinaId,
          ejercicio,
          3,
          esIsometrico ? 60 : 15,
          45,
        );
      }
    }

    const rutinasGimnasio = [
      ['Press plano', 'Crunch normal', 'Sentadilla libre', 'Cinta de correr'],
      ['Remo con mancuerna', 'Flexión de oblicuos con mancuerna', 'Peso muerto', 'Bicicleta estática'],
      ['Press militar con mancuerna', 'Plancha bocaabajo', 'Sentadilla tipo sumo', 'Escaladora'],
      ['Pull over', 'Elevación de piernas en paralelas', 'Hiperextensión de cadera en máquina', 'Remo'],
      ['Halón frontal al pecho', 'Elevación de piernas en banco declinado', 'Patada de glúteo en cuadrupedia', 'Elíptica'],
      ['Halón trasnuca', 'Crunch con piernas en apoyo', 'Extensión de cadera en banco', 'Cinta de correr'],
      ['Curl de bíceps con barra', 'Crunch piernas arriba', 'Patada atrás en banco', 'Bicicleta estática'],
      ['Curl de bíceps con mancuerna', 'Crunch a 90 grados', 'Patada de rana boca abajo', 'Escaladora'],
      ['Copa para tríceps', 'Crunch con polea alta', 'Step con mancuerna para glúteo', 'Remo'],
      ['Push Down', 'Recogimientos', 'Elevación de pelvis para glúteo', 'Elíptica'],
      ['Elevación frontal con barra', 'Abdominales en banco declinado', 'Decúbito supino pierna arriba para glúteo', 'Cinta de correr'],
      ['Press plano', 'Submontañas', 'Prensa invertida', 'Bicicleta estática'],
      ['Halón frontal al pecho', 'Flexión de oblicuos pierna en flexión', 'Buenos días', 'Escaladora'],
      ['Halón trasnuca', 'Crunch lateral en ab slimmer', 'Patada atrás con agarre', 'Remo'],
      ['Curl de bíceps con barra', 'Flexión lateral de torso piernas en flexión', 'Patada atrás con polea baja', 'Elíptica'],
      ['Curl de bíceps con mancuerna', 'Flexión lateral de torso en colchoneta', 'Patada atrás con máquina', 'Cinta de correr'],
      ['Copa para tríceps', 'Flexión lateral de torso con polea alta', 'Aducción de cadera en colchoneta', 'Bicicleta estática'],
      ['Push Down', 'Flexión lateral de torso con polea baja', 'Aducción de cadera en cuadrupedia', 'Escaladora'],
      ['Elevación frontal con barra', 'Giros de oblicuos en polea alta', 'Aductores con polea baja', 'Remo'],
      ['Pull over', 'Flexión de oblicuos en banco en suspensión', 'Aductores en máquina', 'Elíptica'],
    ];

    const cardioMaquina = [
      'Cinta de correr',
      'Elíptica',
      'Bicicleta estática',
      'Escaladora',
      'Remo',
    ];

    for (var i = 0; i < rutinasGimnasio.length; i++) {
      final rutinaId = await insertarRutinaPreestablecida(
        'Rutina ${i + 1}',
        'Gimnasio',
        'Principiante',
        'Hipertrofia',
      );
      for (final ejercicio in rutinasGimnasio[i]) {
        if (cardioMaquina.contains(ejercicio)) {
          await insertarEjercicioPreestablecido(
            rutinaId,
            ejercicio,
            1,
            45,
            0,
          );
        } else {
          await insertarEjercicioPreestablecido(
            rutinaId,
            ejercicio,
            4,
            ejercicio == 'Plancha bocaabajo' ? 20 : 10,
            75,
          );
        }
      }
    }

    const rutinasParque = [
      ['Dominadas', 'Elevación de piernas colgado', 'Sentadillas con salto sobre banco', 'Burpees'],
      ['Dominadas supinas', 'Plancha', 'Zancadas caminando', 'Mountain climbers'],
      ['Fondos en paralelas', 'Rodillas al pecho colgado', 'Step-up en banco', 'Skipping'],
      ['Remo australiano', 'Plancha lateral', 'Sentadilla búlgara', 'Jumping jacks'],
      ['Flexiones manos elevadas en banco', 'Giros rusos', 'Puente de glúteo', 'Sprints cortos'],
      ['Dominadas', 'Plancha', 'Step-up en banco', 'Jumping jacks'],
      ['Dominadas supinas', 'Rodillas al pecho colgado', 'Sentadilla búlgara', 'Sprints cortos'],
      ['Fondos en paralelas', 'Plancha lateral', 'Puente de glúteo', 'Burpees'],
      ['Remo australiano', 'Giros rusos', 'Sentadillas con salto sobre banco', 'Mountain climbers'],
      ['Flexiones manos elevadas en banco', 'Elevación de piernas colgado', 'Zancadas caminando', 'Skipping'],
      ['Dominadas', 'Rodillas al pecho colgado', 'Puente de glúteo', 'Mountain climbers'],
      ['Dominadas supinas', 'Plancha lateral', 'Sentadillas con salto sobre banco', 'Skipping'],
      ['Fondos en paralelas', 'Giros rusos', 'Zancadas caminando', 'Jumping jacks'],
      ['Remo australiano', 'Elevación de piernas colgado', 'Step-up en banco', 'Sprints cortos'],
      ['Flexiones manos elevadas en banco', 'Plancha', 'Sentadilla búlgara', 'Burpees'],
      ['Dominadas', 'Plancha lateral', 'Zancadas caminando', 'Sprints cortos'],
      ['Dominadas supinas', 'Giros rusos', 'Step-up en banco', 'Burpees'],
      ['Fondos en paralelas', 'Elevación de piernas colgado', 'Sentadilla búlgara', 'Mountain climbers'],
      ['Remo australiano', 'Plancha', 'Puente de glúteo', 'Skipping'],
      ['Flexiones manos elevadas en banco', 'Rodillas al pecho colgado', 'Sentadillas con salto sobre banco', 'Jumping jacks'],
    ];

    for (var i = 0; i < rutinasParque.length; i++) {
      final rutinaId = await insertarRutinaPreestablecida(
        'Rutina ${i + 1}',
        'Parque',
        'Principiante',
        'Fuerza funcional',
      );
      for (final ejercicio in rutinasParque[i]) {
        final esIsometrico =
            ejercicio == 'Plancha' || ejercicio == 'Plancha lateral';
        await insertarEjercicioPreestablecido(
          rutinaId,
          ejercicio,
          3,
          esIsometrico ? 60 : 15,
          90,
        );
      }
    }
  }
}