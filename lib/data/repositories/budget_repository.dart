import '../database/database_helper.dart';
import '../models/budget_goal.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(BudgetGoal goal) async {
    final db = await _dbHelper.database;
    return await db.insert('budget_goals', goal.toMap());
  }

  Future<int> update(BudgetGoal goal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budget_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<BudgetGoal?> getByYear(int userId, int year) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'budget_goals',
      where: 'user_id = ? AND year = ?',
      whereArgs: [userId, year],
    );
    if (maps.isEmpty) return null;
    return BudgetGoal.fromMap(maps.first);
  }

  Future<List<BudgetGoal>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'budget_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'year DESC',
    );
    return maps.map((map) => BudgetGoal.fromMap(map)).toList();
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('budget_goals', where: 'id = ?', whereArgs: [id]);
  }
}
