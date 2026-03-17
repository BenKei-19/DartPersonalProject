import '../database/database_helper.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Reminder reminder) async {
    final db = await _dbHelper.database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<int> update(Reminder reminder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Reminder>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_done ASC, remind_date ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getUpcoming(int userId) async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query(
      'reminders',
      where: 'user_id = ? AND is_done = 0 AND remind_date >= ?',
      whereArgs: [userId, today],
      orderBy: 'remind_date ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> markDone(int id, bool done) async {
    final db = await _dbHelper.database;
    return await db.update(
      'reminders',
      {'is_done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
