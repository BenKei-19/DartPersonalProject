import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/relative_category.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../utils/constants.dart';

class CategoryFormScreen extends StatefulWidget {
  final RelativeCategory? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'people';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'Sửa nhóm' : 'Thêm nhóm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên nhóm',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Chọn icon:', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.categoryIcons.entries.map((entry) {
              final isSelected = _selectedIcon == entry.key;
              return InkWell(
                onTap: () => setState(() => _selectedIcon = entry.key),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryRed.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(entry.value, color: isSelected ? AppConstants.primaryRed : Colors.grey),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryRed,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final userId = context.read<AuthViewModel>().currentUser!.id!;
    final catVM = context.read<CategoryViewModel>();

    if (widget.category != null) {
      catVM.updateCategory(widget.category!.copyWith(name: name, icon: _selectedIcon));
    } else {
      catVM.addCategory(RelativeCategory(userId: userId, name: name, icon: _selectedIcon));
    }

    Navigator.pop(context);
  }
}
