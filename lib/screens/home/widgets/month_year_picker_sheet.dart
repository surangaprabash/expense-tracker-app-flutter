import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearPickerSheet extends StatefulWidget {
  final DateTime initialMonth;

  const MonthYearPickerSheet({super.key, required this.initialMonth});

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
    _month = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(16, (i) => now.year - i); // current year + last 15
    final maxMonth = _year == now.year ? now.month : 12;
    if (_month > maxMonth) _month = maxMonth;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jump to month', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _year = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: List.generate(maxMonth, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(DateFormat('MMMM').format(DateTime(_year, m))),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _month = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, DateTime(_year, _month)),
                child: const Text('Go'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}