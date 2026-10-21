import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class MovieDatabase {
  MovieDatabase._();

  static final MovieDatabase instance = MovieDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'movie_search.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE movies (
            tmdb_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            title TEXT NOT NULL,
            year TEXT NOT NULL,
            duration INTEGER NOT NULL,
            genres TEXT NOT NULL,
            director TEXT NOT NULL,
            overview TEXT NOT NULL,
            poster_path TEXT,
            rating REAL NOT NULL,
            searched_at INTEGER NOT NULL,
            PRIMARY KEY (tmdb_id, media_type)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> save(Movie movie) async {
    final db = await database;
    await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movie>> getHistory() async {
    final db = await database;
    final rows = await db.query('movies', orderBy: 'searched_at DESC');
    return rows.map(Movie.fromMap).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('movies');
  }
}
