import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/csv_exporter.dart';
import '../../utils/backup_manager.dart';
import '../categories/category_list_screen.dart';
import '../budget/budget_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & name
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickAvatar(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppConstants.primaryRed.withOpacity(0.1),
                        backgroundImage: user?.avatarPath != null ? FileImage(File(user!.avatarPath!)) : null,
                        child: user?.avatarPath == null
                            ? const Text('🧧', style: TextStyle(fontSize: 40))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('@${user?.username ?? ''}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Profile actions
          _sectionTitle('Tài khoản'),
          _menuTile(Icons.person_outline, 'Đổi tên hiển thị', () => _changeDisplayName(context)),
          _menuTile(Icons.lock_outline, 'Đổi mật khẩu', () => _changePassword(context)),
          const Divider(height: 32),

          // Features
          _sectionTitle('Tính năng'),
          _menuTile(Icons.people, 'Nhóm người thân', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoryListScreen()));
          }),
          _menuTile(Icons.flag, 'Mục tiêu ngân sách', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen()));
          }),
          const Divider(height: 32),

          // Data
          _sectionTitle('Dữ liệu'),
          _menuTile(Icons.table_chart, 'Xuất CSV', () => _exportCsv(context)),
          _menuTile(Icons.backup, 'Sao lưu dữ liệu', () => _backup(context)),
          _menuTile(Icons.restore, 'Khôi phục dữ liệu', () => _restore(context)),
          const Divider(height: 32),

          // Settings
          _sectionTitle('Cài đặt'),
          SwitchListTile(
            value: themeVM.isDarkMode,
            onChanged: (_) => themeVM.toggleTheme(),
            title: const Text('Chế độ tối'),
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(height: 32),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);
    if (xFile != null) {
      context.read<AuthViewModel>().updateAvatar(xFile.path);
    }
  }

  void _changeDisplayName(BuildContext context) {
    final controller = TextEditingController(text: context.read<AuthViewModel>().currentUser?.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Tên mới',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthViewModel>().updateProfile(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryRed, foregroundColor: Colors.white),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<AuthViewModel>().changePassword(oldCtrl.text, newCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Đổi mật khẩu thành công' : 'Đổi mật khẩu thất bại')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryRed, foregroundColor: Colors.white),
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }

  void _exportCsv(BuildContext context) async {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final transactions = await context.read<TransactionViewModel>().getRecentTransactions(userId, limit: 9999);
    await CsvExporter.exportAndShare(transactions);
  }

  void _backup(BuildContext context) async {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final manager = BackupManager();
    await manager.shareBackup(userId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo file sao lưu')));
  }

  void _restore(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng khôi phục: Vui lòng chọn file JSON sao lưu')),
    );
  }
}
