import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/category.dart';
import '../../../models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final ExpenseCategory? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete_outline,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text('Delete "${expense.title}"? This can\'t be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete')),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor:
                (category?.color ?? Colors.grey).withOpacity(0.15),
            child: Icon(category?.icon ?? Icons.category,
                color: category?.color ?? Colors.grey),
          ),
          title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${category?.name ?? 'Uncategorized'} · ${DateFormat('MMM d, yyyy').format(expense.date)}'
            '${expense.note != null && expense.note!.isNotEmpty ? '\n${expense.note}' : ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: expense.note != null && expense.note!.isNotEmpty,
          trailing: Text(
            'LKR ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}