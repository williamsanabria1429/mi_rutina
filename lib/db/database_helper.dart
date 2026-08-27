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
      version: 5,
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
}