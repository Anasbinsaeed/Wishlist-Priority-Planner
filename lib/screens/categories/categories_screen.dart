import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_scaffold.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: provider.categories.isEmpty
          ? EmptyState(
              icon: Icons.label_outline,
              title: 'No categories yet',
              actionLabel: 'Add Category',
              onAction: () => _showAddDialog(context, provider),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: provider.categories.length,
              itemBuilder: (context, i) {
                final cat = provider.categories[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.cardGradientDark
                        : AppColors.cardGradientLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    boxShadow: isDark ? AppShadows.dark : AppShadows.light,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.label_rounded,
                        color: Color(cat.colorValue),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      onPressed: () => _confirmDelete(context, provider, cat),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, CategoryProvider provider) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: AppTextField(
          controller: nameCtrl,
          label: 'Category Name',
          prefixIcon: const Icon(Icons.label_outline, size: 20),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
            variant: AppButtonVariant.outline,
            fullWidth: false,
          ),
          const SizedBox(width: 8),
          AppButton(
            label: 'Add',
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                provider.addCategory(nameCtrl.text.trim(), 'other', 0xFF9E9E9E);
                Navigator.pop(ctx);
              }
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    WishCategory cat,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Category',
      message: 'Delete "${cat.name}"?',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (confirmed) provider.deleteCategory(cat.id);
  }
}
