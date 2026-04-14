import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/wish.dart';
import '../../providers/wish_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/wish_form_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_deadline_picker.dart';
import '../../widgets/app_button.dart';
import '../../widgets/gradient_scaffold.dart';

class WishFormScreen extends StatefulWidget {
  final String? wishId;
  const WishFormScreen({super.key, this.wishId});

  @override
  State<WishFormScreen> createState() => _WishFormScreenState();
}

class _WishFormScreenState extends State<WishFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  bool _isEdit = false;
  bool _isSubmitting = false;
  Wish? _existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishFormProvider>().reset();
      if (widget.wishId != null) {
        _isEdit = true;
        _loadExisting();
      }
    });
  }

  void _loadExisting() {
    final wish = context.read<WishProvider>().wishes.cast<Wish?>().firstWhere(
      (w) => w?.id == widget.wishId,
      orElse: () => null,
    );
    if (wish != null) {
      _existing = wish;
      _titleCtrl.text = wish.title;
      _descCtrl.text = wish.description ?? '';
      _notesCtrl.text = wish.notes ?? '';
      _tagsCtrl.text = wish.tags.join(', ');
      context.read<WishFormProvider>().loadFromWish(wish);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final formProvider = context.read<WishFormProvider>();
    if (formProvider.categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    _isSubmitting = true;
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final wishProvider = context.read<WishProvider>();
    if (_isEdit && _existing != null) {
      await wishProvider.updateWish(
        _existing!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          categoryId: formProvider.categoryId,
          priority: formProvider.priority,
          deadline: formProvider.deadline,
          notes: _notesCtrl.text.trim(),
          tags: tags,
        ),
      );
    } else {
      await wishProvider.addWish(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryId: formProvider.categoryId!,
        priority: formProvider.priority,
        deadline: formProvider.deadline,
        notes: _notesCtrl.text.trim(),
        tags: tags,
      );
    }
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final formProvider = context.watch<WishFormProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Wish' : 'New Wish')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _FormSection(
              title: 'Basic Info',
              isDark: isDark,
              children: [
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Title *',
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormSection(
              title: 'Details',
              isDark: isDark,
              children: [
                AppDropdown<String>(
                  initialValue: formProvider.categoryId,
                  label: 'Category *',
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: context.read<WishFormProvider>().setCategoryId,
                  validator: (v) =>
                      v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 12),
                AppDropdown<WishPriority>(
                  initialValue: formProvider.priority,
                  label: 'Priority',
                  items: WishPriority.values
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null)
                      context.read<WishFormProvider>().setPriority(v);
                  },
                ),
                const SizedBox(height: 12),
                AppDeadlinePicker(
                  deadline: formProvider.deadline,
                  onPicked: context.read<WishFormProvider>().setDeadline,
                  onClear: () =>
                      context.read<WishFormProvider>().setDeadline(null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormSection(
              title: 'Extra',
              isDark: isDark,
              children: [
                AppTextField(
                  controller: _tagsCtrl,
                  label: 'Tags',
                  hint: 'travel, bucket-list (comma separated)',
                  prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _notesCtrl,
                  label: 'Notes',
                  maxLines: 3,
                  prefixIcon: const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Add Wish',
              onPressed: _submit,
              isLoading: _isSubmitting,
              icon: _isEdit ? Icons.check_rounded : Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _FormSection({
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.dark : AppShadows.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
