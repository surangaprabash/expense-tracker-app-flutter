import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(text: e != null ? e.amount.toString() : '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _categoryId = e?.categoryId;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expenseProvider = context.read<ExpenseProvider>();
    final category = context.read<CategoryProvider>().byId(_categoryId!);
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();

    try {
      if (_isEditing) {
        await expenseProvider.updateExpense(widget.expense!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          categoryId: _categoryId,
          date: _date,
          note: note.isEmpty ? null : note,
          categoryName: category?.name,
          categoryColorValue: category?.color.value,
          categoryIconCodePoint: category?.icon.codePoint,
        ));
      } else {
        await expenseProvider.addExpense(Expense(
          id: '', // ignored by Firestore's .add(); doc gets its own generated id
          title: _titleController.text.trim(),
          amount: amount,
          categoryId: _categoryId!,
          date: _date,
          note: note.isEmpty ? null : note,
          categoryName: category?.name,
          categoryColorValue: category?.color.value,
          categoryIconCodePoint: category?.icon.codePoint,
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Check your internet connection.')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Delete "${widget.expense!.title}"? This can\'t be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await context.read<ExpenseProvider>().deleteExpense(widget.expense!.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete. Check your internet connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().active;
    final currentCategory = context.watch<CategoryProvider>().byId(_categoryId ?? '');
    final dropdownItems = [
      ...categories,
      if (currentCategory != null && !categories.contains(currentCategory)) currentCategory,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: 'LKR '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null) return 'Enter a valid number';
                    if (parsed <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: _isSaving ? null : (v) => setState(() => _categoryId = v),
                  items: dropdownItems
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(c.icon, size: 18, color: c.color),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          ))
                      .toList(),
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _isSaving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(DateFormat('MMM d, yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isEditing ? 'Save Changes' : 'Add Expense'),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _confirmDelete,
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    label: Text('Delete Expense',
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}