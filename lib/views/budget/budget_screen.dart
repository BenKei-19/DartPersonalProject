import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) context.read<BudgetViewModel>().loadBudget(userId, _year);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetVM = context.watch<BudgetViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu ngân sách'),
        actions: [
          DropdownButton<int>(
            value: _year,
            underline: const SizedBox.shrink(),
            items: List.generate(5, (i) {
              final y = DateTime.now().year + i - 2;
              return DropdownMenuItem(value: y, child: Text('$y'));
            }),
            onChanged: (y) {
              if (y == null) return;
              setState(() => _year = y);
              _loadData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Năm $_year',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (budgetVM.hasGoal) ...[
                      BudgetProgressBar(
                        target: budgetVM.currentGoal!.targetAmount,
                        spent: budgetVM.totalSpent,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Còn lại: ${Formatters.formatCurrency(budgetVM.remaining > 0 ? budgetVM.remaining : 0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: budgetVM.remaining > 0 ? AppConstants.receivedGreen : Colors.red,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showSetGoalDialog(budgetVM.currentGoal?.targetAmount),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Sửa'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'Chưa đặt mục tiêu cho năm này',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showSetGoalDialog(null),
                          icon: const Icon(Icons.add),
                          label: const Text('Đặt mục tiêu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('💡 Gợi ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Đặt mục tiêu ngân sách giúp bạn kiểm soát chi tiêu lì xì mỗi năm. '
                  'Thanh tiến trình sẽ đổi màu khi bạn gần đạt hoặc vượt mục tiêu.',
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetGoalDialog(double? currentAmount) {
    if (currentAmount != null) {
      _amountController.text = currentAmount.toStringAsFixed(0);
    } else {
      _amountController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt mục tiêu'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Số tiền mục tiêu (VNĐ)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) return;
              final userId = context.read<AuthViewModel>().currentUser?.id;
              if (userId != null) {
                context.read<BudgetViewModel>().setGoal(userId, _year, amount);
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
}
