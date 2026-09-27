import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSummaryCard extends StatelessWidget {
  final double total;

  const MonthSummaryCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spent · $monthLabel',
            style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'LKR ${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}