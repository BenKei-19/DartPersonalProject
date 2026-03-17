import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class SuggestionChip extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.lightbulb_outline, size: 16),
      label: Text(
        'Gợi ý: ${Formatters.formatCurrency(amount)}',
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: onTap,
      backgroundColor: Colors.amber[50],
      side: const BorderSide(color: Colors.amber),
    );
  }
}
