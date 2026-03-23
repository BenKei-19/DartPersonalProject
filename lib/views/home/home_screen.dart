import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/reminder_viewmodel.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/countdown_widget.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../transactions/transaction_list_screen.dart';
import '../statistics/statistics_screen.dart';
import '../reminders/reminder_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final year = DateTime.now().year;
    context.read<TransactionViewModel>().loadTransactions(userId);
    context.read<BudgetViewModel>().loadBudget(userId, year);
    context.read<ReminderViewModel>().loadReminders(userId);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(onRefresh: _loadData),
      const TransactionListScreen(),
      const StatisticsScreen(),
      const ReminderScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryRed,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Nhắc nhở'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _DashboardTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final txnVM = context.watch<TransactionViewModel>();
    final budgetVM = context.watch<BudgetViewModel>();
    final userId = auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào, ${auth.currentUser?.displayName ?? ''}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: AppConstants.primaryRed),
            tooltip: 'Thêm bằng giọng nói',
            onPressed: () => Navigator.of(context).pushNamed('/voice-transaction').then((_) => onRefresh()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Tổng nhận',
                    amount: txnVM.totalReceived,
                    icon: Icons.arrow_downward,
                    color: AppConstants.receivedGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SummaryCard(
                    title: 'Tổng cho',
                    amount: txnVM.totalGiven,
                    icon: Icons.arrow_upward,
                    color: AppConstants.givenOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SummaryCard(
              title: 'Số dư',
              amount: txnVM.balance,
              icon: Icons.account_balance_wallet,
              color: txnVM.balance >= 0 ? AppConstants.primaryRed : Colors.grey,
            ),
            const SizedBox(height: 16),

            // Budget progress
            if (budgetVM.hasGoal) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯 Mục tiêu ngân sách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      BudgetProgressBar(target: budgetVM.currentGoal!.targetAmount, spent: budgetVM.totalSpent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Countdown
            const CountdownWidget(),
            const SizedBox(height: 16),

            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giao dịch gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () {
                    // Switch to transactions tab - handled by parent
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            FutureBuilder<List<LixiTransaction>>(
              future: userId != null ? txnVM.getRecentTransactions(userId) : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long,
                    message: 'Chưa có giao dịch nào',
                  );
                }
                return Column(
                  children: snapshot.data!.map((t) => TransactionCard(
                    transaction: t,
                    onTap: () => Navigator.of(context).pushNamed('/transaction-form', arguments: t).then((_) => onRefresh()),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/transaction-form').then((_) => onRefresh()),
        backgroundColor: AppConstants.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
