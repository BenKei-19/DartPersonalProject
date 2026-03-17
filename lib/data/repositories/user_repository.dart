import '../database/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> register(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> login(String username, String passwordHash) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> updateProfile(int userId, String displayName) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      {'display_name': displayName},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateAvatar(int userId, String avatarPath) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      {'avatar_path': avatarPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> changePassword(int userId, String newPasswordHash) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      {'password_hash': newPasswordHash},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }
}
