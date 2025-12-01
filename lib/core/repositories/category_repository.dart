import '../database/app_db.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDB _dbProvider = AppDB.instance;

  /// Insere categoria
  Future<int> insert(CategoryModel cat) async {
    final db = await _dbProvider.database;
    final map = Map<String, dynamic>.from(cat.toMap());
    // If id is null, don't include it so AUTOINCREMENT works reliably
    if (map['id'] == null) map.remove('id');
    return await db.insert('categories', map);
  }

  /// Lista todas as categorias
  Future<List<CategoryModel>> getAll() async {
    final db = await _dbProvider.database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map((r) => CategoryModel.fromMap(r)).toList();
  }

  /// Atualiza categoria
  Future<int> update(CategoryModel cat) async {
    final db = await _dbProvider.database;
    return await db.update(
      'categories',
      cat.toMap(),
      where: 'id = ?',
      whereArgs: [cat.id],
    );
  }

  /// Deleta categoria
  Future<int> delete(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
