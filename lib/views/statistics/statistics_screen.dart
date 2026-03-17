import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/statistics_viewmodel.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<int> _years = [];
  int? _compareYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() async {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final statsVM = context.read<StatisticsViewModel>();
    _years = await statsVM.getAvailableYears(userId);
    final year = _years.isNotEmpty ? _years.first : DateTime.now().year;
    await statsVM.loadStatistics(userId, year);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final statsVM = context.watch<StatisticsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        automaticallyImplyLeading: false,
        actions: [
          if (_years.isNotEmpty)
            DropdownButton<int>(
              value: statsVM.selectedYear,
              underline: const SizedBox.shrink(),
              items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (y) {
                if (y == null) return;
                final userId = context.read<AuthViewModel>().currentUser?.id;
                if (userId != null) statsVM.loadStatistics(userId, y);
              },
            ),
        ],
      ),
      body: statsVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : statsVM.categoryStats.isEmpty && statsVM.totalReceived == 0
              ? const EmptyState(icon: Icons.bar_chart, message: 'Chưa có dữ liệu thống kê')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('Tổng nhận', statsVM.totalReceived, AppConstants.receivedGreen),
                              Container(width: 1, height: 40, color: Colors.grey[300]),
                              _statItem('Tổng cho', statsVM.totalGiven, AppConstants.givenOrange),
                              Container(width: 1, height: 40, color: Colors.grey[300]),
                              _statItem('Số dư', statsVM.totalReceived - statsVM.totalGiven, AppConstants.primaryRed),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pie chart
                      const Text('Phân bổ theo nhóm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            height: 200,
                            child: CategoryPieChart(data: statsVM.categoryStats),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bar chart
                      const Text('Thu–chi theo tháng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: MonthlyBarChart(data: statsVM.monthlyStats),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Year comparison
                      if (_years.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('So sánh năm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            DropdownButton<int>(
                              value: _compareYear,
                              hint: const Text('Chọn năm'),
                              underline: const SizedBox.shrink(),
                              items: _years
                                  .where((y) => y != statsVM.selectedYear)
                                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                                  .toList(),
                              onChanged: (y) {
                                if (y == null) return;
                                setState(() => _compareYear = y);
                                final userId = context.read<AuthViewModel>().currentUser?.id;
                                if (userId != null) statsVM.loadCompareYear(userId, y);
                              },
                            ),
                          ],
                        ),
                        if (statsVM.compareMonthlyStats != null)
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: MonthlyBarChart(
                                data: statsVM.compareMonthlyStats!,
                                title: 'Năm $_compareYear',
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _statItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCompactCurrency(amount),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
      ],
    );
  }
}
