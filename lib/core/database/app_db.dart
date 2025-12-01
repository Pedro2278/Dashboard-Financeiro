import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDB {
  static final AppDB instance = AppDB._init();
  static Database? _database;

  AppDB._init();

  /// Retorna ou cria o banco
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dashboard_financeiro.db');
    return _database!;
  }

  /// Inicialização do banco
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Ativa Foreign Keys no SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Upgrade: adiciona colunas faltantes ou recria tabela se corrompida
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      try {
        // Verifica quais colunas existem na tabela categories
        final columns = await db.rawQuery("PRAGMA table_info(categories)");
        final columnNames = columns.map((col) => col['name']).toSet();

        // Se faltam colunas essenciais, recria a tabela com dados preservados
        if (!columnNames.contains('isIncome') ||
            !columnNames.contains('color')) {
          // Salva dados existentes
          final existingData = await db.query('categories');

          // Drop e recria tabela
          await db.execute('DROP TABLE IF EXISTS categories');
          await db.execute('''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              isIncome INTEGER NOT NULL,
              color INTEGER NOT NULL
            );
          ''');

          // Reinsere dados, preenchendo colunas faltantes com defaults
          for (var row in existingData) {
            await db.insert('categories', {
              'id': row['id'],
              'name': row['name'],
              'isIncome': row['isIncome'] ?? 0,
              'color': row['color'] ?? 4280391411,
            });
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('AppDB._onUpgrade error: $e');
      }
    }
  }

  /// Criação das tabelas
  Future _createDB(Database db, int version) async {
    // ------- TABELA CATEGORIES -------
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        color INTEGER NOT NULL
      );
    ''');

    // ------- TABELA TRANSACTIONS -------
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        categoryId INTEGER,
        FOREIGN KEY (categoryId)
          REFERENCES categories (id)
          ON DELETE SET NULL
      );
    ''');
  }

  /// Fecha o banco
  Future close() async {
    final db = await database;
    db.close();
  }
}
