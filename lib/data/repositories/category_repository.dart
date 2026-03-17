import '../database/database_helper.dart';
import '../models/relative_category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(RelativeCategory category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> update(RelativeCategory category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    // Set category_id to null for transactions using this category
    await db.update(
      'transactions',
      {'category_id': null},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RelativeCategory>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => RelativeCategory.fromMap(map)).toList();
  }

  Future<RelativeCategory?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return RelativeCategory.fromMap(maps.first);
  }

  Future<void> insertDefaultCategories(int userId) async {
    final defaults = [
      'Ông Bà',
      'Bố Mẹ',
      'Cô Chú',
      'Anh Chị',
      'Bạn bè',
      'Đồng nghiệp',
      'Hàng xóm',
      'Khác',
    ];
    for (final name in defaults) {
      await insert(RelativeCategory(userId: userId, name: name));
    }
  }
}
