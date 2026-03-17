import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    context.read<TransactionViewModel>().loadTransactions(userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnVM = context.watch<TransactionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<TransactionSort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) => txnVM.setSort(sort),
            itemBuilder: (_) => [
              const PopupMenuItem(value: TransactionSort.dateDesc, child: Text('Ngày ↓ (Mới nhất)')),
              const PopupMenuItem(value: TransactionSort.dateAsc, child: Text('Ngày ↑ (Cũ nhất)')),
              const PopupMenuItem(value: TransactionSort.amountDesc, child: Text('Số tiền ↓')),
              const PopupMenuItem(value: TransactionSort.amountAsc, child: Text('Số tiền ↑')),
              const PopupMenuItem(value: TransactionSort.nameAsc, child: Text('Tên A-Z')),
              const PopupMenuItem(value: TransactionSort.nameDesc, child: Text('Tên Z-A')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: txnVM.setSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          txnVM.setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('Tất cả', TransactionFilter.all, txnVM),
                const SizedBox(width: 8),
                _filterChip('Nhận', TransactionFilter.received, txnVM),
                const SizedBox(width: 8),
                _filterChip('Cho', TransactionFilter.given, txnVM),
              ],
            ),
          ),
          // List
          Expanded(
            child: txnVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : txnVM.transactions.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long,
                        message: 'Chưa có giao dịch nào',
                        actionLabel: 'Thêm giao dịch',
                        onAction: () => Navigator.of(context).pushNamed('/transaction-form').then((_) => _loadData()),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: txnVM.transactions.length,
                          itemBuilder: (context, index) {
                            final t = txnVM.transactions[index];
                            return Dismissible(
                              key: Key('txn_${t.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa giao dịch?'),
                                    content: Text('Xóa giao dịch với ${t.personName}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ) ?? false;
                              },
                              onDismissed: (_) {
                                final userId = context.read<AuthViewModel>().currentUser?.id;
                                if (userId != null) txnVM.deleteTransaction(t.id!, userId);
                              },
                              child: TransactionCard(
                                transaction: t,
                                onTap: () => Navigator.of(context).pushNamed('/transaction-form', arguments: t).then((_) => _loadData()),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/transaction-form').then((_) => _loadData()),
        backgroundColor: AppConstants.primaryRed,
        heroTag: 'txn_fab',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _filterChip(String label, TransactionFilter filter, TransactionViewModel vm) {
    final isSelected = vm.filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setFilter(filter),
      selectedColor: AppConstants.primaryRed.withOpacity(0.15),
      checkmarkColor: AppConstants.primaryRed,
    );
  }
}
