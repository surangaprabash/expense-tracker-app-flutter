import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    IconData selectedIcon = kCategoryIconChoices.first;
    Color selectedColor = kCategoryColorChoices.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                const Text('Icon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCategoryIconChoices.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: CircleAvatar(
                        backgroundColor: isSelected
                            ? selectedColor.withOpacity(0.25)
                            : Colors.grey.withOpacity(0.15),
                        child: Icon(icon,
                            color: isSelected ? selectedColor : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCategoryColorChoices.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                context.read<CategoryProvider>().addCustom(name, selectedIcon, selectedColor);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final c = categories[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: c.color.withOpacity(0.15),
                child: Icon(c.icon, color: c.color),
              ),
              title: Text(c.name),
              subtitle: Text(c.isDefault ? 'Default category' : 'Custom category'),
              trailing: c.isDefault
                  ? Switch(
                      value: c.isEnabled,
                      onChanged: (_) => categoryProvider.toggleEnabled(c.id),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => categoryProvider.removeCustom(c.id),
                    ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
    );
  }
}