import 'package:album_viewer/models/album.dart';
import 'package:album_viewer/models/photo.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'album_viewer.db';
  static const _databaseVersion = 1;

  static const albumTable = 'albums';
  static const photoTable = 'photos';

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $albumTable (
        id INTEGER PRIMARY KEY,
        title TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $photoTable (
        id INTEGER PRIMARY KEY,
        albumId INTEGER,
        url TEXT
      )
    ''');
  }

  Future<void> insertAlbums(List<Album> albums) async {
    final db = await database;
    for (final album in albums) {
      await db.insert(albumTable, album.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> insertPhotos(List<Photo> photos) async {
    final db = await database;
    for (final photo in photos) {
      await db.insert(photoTable, photo.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Album>> fetchAlbums() async {
    final db = await database;
    final result = await db.query(albumTable);
    return result.map((json) => Album.fromJson(json)).toList();
  }

  Future<List<Photo>> fetchPhotos(int albumId) async {
    final db = await database;
    final result =
        await db.query(photoTable, where: 'albumId = ?', whereArgs: [albumId]);
    return result.map((json) => Photo.fromJson(json)).toList();
  }

  Future<void> clearData() async {
    final db = await database;
    await db.delete(albumTable);
    await db.delete(photoTable);
  }
}
