import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database/database_helper.dart';

class BackupManager {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> exportToJson(int userId) async {
    final db = await _dbHelper.database;

    final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    final categories = await db.query('categories', where: 'user_id = ?', whereArgs: [userId]);
    final transactions = await db.query('transactions', where: 'user_id = ?', whereArgs: [userId]);
    final budgetGoals = await db.query('budget_goals', where: 'user_id = ?', whereArgs: [userId]);
    final reminders = await db.query('reminders', where: 'user_id = ?', whereArgs: [userId]);

    final backup = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'user': users.isNotEmpty ? users.first : null,
      'categories': categories,
      'transactions': transactions,
      'budget_goals': budgetGoals,
      'reminders': reminders,
    };

    return jsonEncode(backup);
  }

  Future<File> exportToFile(int userId) async {
    final jsonStr = await exportToJson(userId);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/lixi_backup_$timestamp.json');
    await file.writeAsString(jsonStr);
    return file;
  }

  Future<void> shareBackup(int userId) async {
    final file = await exportToFile(userId);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Lì Xì Tracker Backup',
    );
  }

  Future<bool> importFromJson(String jsonStr, int userId) async {
    try {
      final db = await _dbHelper.database;
      final backup = jsonDecode(jsonStr) as Map<String, dynamic>;

      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('reminders', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('budget_goals', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('categories', where: 'user_id = ?', whereArgs: [userId]);

        // Import categories
        final categories = backup['categories'] as List<dynamic>? ?? [];
        final categoryIdMap = <int, int>{};
        for (final cat in categories) {
          final oldId = cat['id'] as int;
          final newCat = Map<String, dynamic>.from(cat as Map);
          newCat.remove('id');
          newCat['user_id'] = userId;
          final newId = await txn.insert('categories', newCat);
          categoryIdMap[oldId] = newId;
        }

        // Import transactions
        final transactions = backup['transactions'] as List<dynamic>? ?? [];
        for (final trans in transactions) {
          final newTrans = Map<String, dynamic>.from(trans as Map);
          newTrans.remove('id');
          newTrans['user_id'] = userId;
          if (newTrans['category_id'] != null) {
            newTrans['category_id'] = categoryIdMap[newTrans['category_id']];
          }
          await txn.insert('transactions', newTrans);
        }

        // Import budget goals
        final budgetGoals = backup['budget_goals'] as List<dynamic>? ?? [];
        for (final goal in budgetGoals) {
          final newGoal = Map<String, dynamic>.from(goal as Map);
          newGoal.remove('id');
          newGoal['user_id'] = userId;
          await txn.insert('budget_goals', newGoal);
        }

        // Import reminders
        final reminders = backup['reminders'] as List<dynamic>? ?? [];
        for (final rem in reminders) {
          final newRem = Map<String, dynamic>.from(rem as Map);
          newRem.remove('id');
          newRem['user_id'] = userId;
          await txn.insert('reminders', newRem);
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
