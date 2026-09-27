import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/category.dart';

class FilterSheet extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final String? initialCategoryId;
  final DateTime? initialDate;

  const FilterSheet({
    super.key,
    required this.categories,
    this.initialCategoryId,
    this.initialDate,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _categoryId;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _date = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter expenses', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All categories')),
                ...widget.categories.map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_date == null
                        ? 'Any date'
                        : DateFormat('MMM d, yyyy').format(_date!)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ),
                if (_date != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _date = null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(
                        context, {'category': null, 'date': null, 'clear': true}),
                    child: const Text('Clear filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                        context, {'category': _categoryId, 'date': _date, 'clear': false}),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}