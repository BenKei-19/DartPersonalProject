import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

class BudgetProgressBar extends StatelessWidget {
  final double target;
  final double spent;

  const BudgetProgressBar({
    super.key,
    required this.target,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final color = progress > 0.9
        ? Colors.red
        : progress > 0.7
            ? Colors.orange
            : AppConstants.receivedGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã chi: ${Formatters.formatCurrency(spent)}',
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
            Text(
              'Mục tiêu: ${Formatters.formatCurrency(target)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% ngân sách',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
