import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/relative_category.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) context.read<CategoryViewModel>().loadCategories(userId);
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nhóm người thân')),
      body: catVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : catVM.categories.isEmpty
              ? EmptyState(
                  icon: Icons.people,
                  message: 'Chưa có nhóm nào',
                  actionLabel: 'Thêm nhóm',
                  onAction: () => _showForm(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: catVM.categories.length,
                  itemBuilder: (context, index) {
                    final cat = catVM.categories[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryRed.withOpacity(0.1),
                          child: Icon(
                            AppConstants.categoryIcons[cat.icon] ?? Icons.people,
                            color: AppConstants.primaryRed,
                          ),
                        ),
                        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showForm(context, cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _confirmDelete(context, cat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: AppConstants.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showForm(BuildContext context, [RelativeCategory? category]) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormScreen(category: category),
    ).then((_) => _loadData());
  }

  void _confirmDelete(BuildContext context, RelativeCategory cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nhóm?'),
        content: Text('Bạn có chắc muốn xóa nhóm "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final userId = context.read<AuthViewModel>().currentUser?.id;
              if (userId != null) context.read<CategoryViewModel>().deleteCategory(cat.id!, userId);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
