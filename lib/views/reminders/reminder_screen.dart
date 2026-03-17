import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/reminder.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reminder_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) context.read<ReminderViewModel>().loadReminders(userId);
  }

  @override
  Widget build(BuildContext context) {
    final remVM = context.watch<ReminderViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắc nhở lì xì'),
        automaticallyImplyLeading: false,
      ),
      body: remVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : remVM.reminders.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none,
                  message: 'Chưa có nhắc nhở nào',
                  actionLabel: 'Thêm nhắc nhở',
                  onAction: () => _showForm(context),
                )
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    if (remVM.pendingReminders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Chưa thực hiện (${remVM.pendingCount})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ...remVM.pendingReminders.map((r) => _reminderCard(r, false)),
                    ],
                    if (remVM.completedReminders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Đã hoàn thành (${remVM.completedReminders.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                        ),
                      ),
                      ...remVM.completedReminders.map((r) => _reminderCard(r, true)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: AppConstants.primaryRed,
        heroTag: 'reminder_fab',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _reminderCard(Reminder reminder, bool isDone) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetail(context, reminder),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Checkbox(
            value: isDone,
            activeColor: AppConstants.receivedGreen,
            onChanged: (v) {
              final userId = context.read<AuthViewModel>().currentUser?.id;
              if (userId != null) {
                context.read<ReminderViewModel>().toggleDone(reminder.id!, v ?? false, userId);
              }
            },
          ),
          title: Text(
            'Lì xì cho ${reminder.personName}',
            style: TextStyle(
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? Colors.grey : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.amount != null)
                Text(Formatters.formatCurrency(reminder.amount!),
                    style: TextStyle(color: isDone ? Colors.grey : AppConstants.primaryRed)),
              Text(
                '📅 ${Formatters.formatDateString(reminder.remindDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                onPressed: () => _showForm(context, reminder),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () {
                  final userId = context.read<AuthViewModel>().currentUser?.id;
                  if (userId != null) context.read<ReminderViewModel>().deleteReminder(reminder.id!, userId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chi tiết nhắc nhở'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailItem(Icons.person, 'Người nhận', reminder.personName),
            if (reminder.amount != null) _detailItem(Icons.attach_money, 'Số tiền', Formatters.formatCurrency(reminder.amount!)),
            _detailItem(Icons.calendar_today, 'Ngày nhắc', Formatters.formatDateString(reminder.remindDate)),
            if (reminder.note != null && reminder.note!.isNotEmpty) _detailItem(Icons.note, 'Ghi chú', reminder.note!),
            _detailItem(Icons.check_circle_outline, 'Trạng thái', reminder.isDone ? 'Đã hoàn thành' : 'Chưa thực hiện'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showForm(context, reminder);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryRed, foregroundColor: Colors.white),
            child: const Text('Chỉnh sửa'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryRed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, [Reminder? existing]) {
    final personCtrl = TextEditingController(text: existing?.personName ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount?.toStringAsFixed(0) ?? '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    var selectedDate = existing != null ? DateTime.tryParse(existing.remindDate) ?? DateTime.now() : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Sửa nhắc nhở' : 'Thêm nhắc nhở'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: personCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tên người',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tiền (tùy chọn)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ngày nhắc',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (personCtrl.text.trim().isEmpty) return;
                final userId = context.read<AuthViewModel>().currentUser!.id!;
                final reminder = Reminder(
                  id: existing?.id,
                  userId: userId,
                  personName: personCtrl.text.trim(),
                  amount: double.tryParse(amountCtrl.text),
                  remindDate: selectedDate.toIso8601String().substring(0, 10),
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  isDone: existing?.isDone ?? false,
                );
                final remVM = context.read<ReminderViewModel>();
                if (existing != null) {
                  remVM.updateReminder(reminder);
                } else {
                  remVM.addReminder(reminder);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryRed, foregroundColor: Colors.white),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
