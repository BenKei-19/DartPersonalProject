import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(LixiTransaction transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> update(LixiTransaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LixiTransaction>> getAll(int userId, {int? year}) async {
    final db = await _dbHelper.database;
    String whereClause = 't.user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (year != null) {
      whereClause += ' AND t.year = ?';
      whereArgs.add(year);
    }

    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE $whereClause
      ORDER BY t.date DESC, t.created_at DESC
    ''', whereArgs);

    return maps.map((map) => LixiTransaction.fromMap(map)).toList();
  }

  Future<List<LixiTransaction>> getByDateRange(
    int userId,
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.date >= ? AND t.date <= ?
      ORDER BY t.date DESC
    ''', [userId, startDate, endDate]);

    return maps.map((map) => LixiTransaction.fromMap(map)).toList();
  }

  Future<List<LixiTransaction>> search(int userId, String query) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND (t.person_name LIKE ? OR t.note LIKE ?)
      ORDER BY t.date DESC
    ''', [userId, '%$query%', '%$query%']);

    return maps.map((map) => LixiTransaction.fromMap(map)).toList();
  }

  Future<double> getTotalReceived(int userId, {int? year}) async {
    final db = await _dbHelper.database;
    String whereClause = "user_id = ? AND type = 'received'";
    List<dynamic> whereArgs = [userId];
    if (year != null) {
      whereClause += ' AND year = ?';
      whereArgs.add(year);
    }
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalGiven(int userId, {int? year}) async {
    final db = await _dbHelper.database;
    String whereClause = "user_id = ? AND type = 'given'";
    List<dynamic> whereArgs = [userId];
    if (year != null) {
      whereClause += ' AND year = ?';
      whereArgs.add(year);
    }
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getStatsByCategory(int userId, {int? year}) async {
    final db = await _dbHelper.database;
    String whereClause = 't.user_id = ?';
    List<dynamic> whereArgs = [userId];
    if (year != null) {
      whereClause += ' AND t.year = ?';
      whereArgs.add(year);
    }

    final maps = await db.rawQuery('''
      SELECT COALESCE(c.name, 'Chưa phân loại') as category_name, SUM(t.amount) as total
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE $whereClause
      GROUP BY c.name
    ''', whereArgs);

    final result = <String, double>{};
    for (final map in maps) {
      result[map['category_name'] as String] = (map['total'] as num).toDouble();
    }
    return result;
  }

  Future<Map<int, Map<String, double>>> getStatsByMonth(int userId, int year) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        CAST(substr(date, 6, 2) AS INTEGER) as month,
        type,
        SUM(amount) as total
      FROM transactions
      WHERE user_id = ? AND year = ?
      GROUP BY month, type
    ''', [userId, year]);

    final result = <int, Map<String, double>>{};
    for (int i = 1; i <= 12; i++) {
      result[i] = {'received': 0.0, 'given': 0.0};
    }
    for (final map in maps) {
      final month = map['month'] as int;
      final type = map['type'] as String;
      final total = (map['total'] as num).toDouble();
      result[month]![type] = total;
    }
    return result;
  }

  Future<List<int>> getAvailableYears(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT year FROM transactions WHERE user_id = ? ORDER BY year DESC
    ''', [userId]);
    return maps.map((map) => map['year'] as int).toList();
  }

  Future<double> getAverageByCategory(int userId, int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(AVG(amount), 0) as avg_amount
      FROM transactions
      WHERE user_id = ? AND category_id = ?
    ''', [userId, categoryId]);
    return (result.first['avg_amount'] as num).toDouble();
  }

  Future<List<LixiTransaction>> getRecentTransactions(int userId, {int limit = 5}) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ?
      ORDER BY t.date DESC, t.created_at DESC
      LIMIT ?
    ''', [userId, limit]);
    return maps.map((map) => LixiTransaction.fromMap(map)).toList();
  }
}
