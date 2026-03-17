import 'package:flutter/material.dart';
import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';

class ReminderViewModel extends ChangeNotifier {
  final ReminderRepository _repo = ReminderRepository();

  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  List<Reminder> get pendingReminders => _reminders.where((r) => !r.isDone).toList();
  List<Reminder> get completedReminders => _reminders.where((r) => r.isDone).toList();
  int get pendingCount => pendingReminders.length;
  bool get isLoading => _isLoading;

  Future<void> loadReminders(int userId) async {
    _isLoading = true;
    notifyListeners();

    _reminders = await _repo.getAll(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _repo.insert(reminder);
    await loadReminders(reminder.userId);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _repo.update(reminder);
    await loadReminders(reminder.userId);
  }

  Future<void> deleteReminder(int id, int userId) async {
    await _repo.delete(id);
    await loadReminders(userId);
  }

  Future<void> toggleDone(int id, bool done, int userId) async {
    await _repo.markDone(id, done);
    await loadReminders(userId);
  }
}
