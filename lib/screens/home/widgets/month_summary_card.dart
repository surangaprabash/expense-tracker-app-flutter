import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSummaryCard extends StatelessWidget {
  final DateTime month;
  final double total;
  final VoidCallback onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback onTapMonth;

  const MonthSummaryCard({
    super.key,
    required this.month,
    required this.total,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTapMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(month);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: scheme.onPrimaryContainer),
            onPressed: onPreviousMonth,
            tooltip: 'Previous month',
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTapMonth,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(monthLabel,
                          style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 16, color: scheme.onPrimaryContainer),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: onNextMonth == null
                    ? scheme.onPrimaryContainer.withOpacity(0.3)
                    : scheme.onPrimaryContainer),
            onPressed: onNextMonth,
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}