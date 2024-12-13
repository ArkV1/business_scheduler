import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appointment_app/features/services/providers/service_categories_provider.dart';
import 'package:appointment_app/features/services/models/service_category.dart';
import 'package:appointment_app/features/services/services/category_management_service.dart';
import 'package:appointment_app/features/admin/widgets/admin_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(serviceCategoriesProvider);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AdminAppBar(
        title: l10n.manageCategories,
        backPath: '/admin/services',
      ),
      body: categories.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCategories,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _initializeDefaultCategories(context, ref),
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.initializeDefaultCategories),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              _reorderCategories(context, ref, categories, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                key: ValueKey(category.id),
                category: category,
                onEdit: () => _showCategoryDialog(context, ref, category),
                onDelete: () => _showDeleteDialog(context, ref, category),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.error(error.toString())),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        tooltip: l10n.addNewCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _initializeDefaultCategories(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.initializeCategoriesConfirmTitle),
        content: Text(l10n.initializeCategoriesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.initialize),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(categoryManagementProvider).initializeDefaultCategories();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoriesInitialized)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _reorderCategories(
    BuildContext context,
    WidgetRef ref,
    List<ServiceCategory> categories,
    int oldIndex,
    int newIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final category = categories[oldIndex];
      final batch = <Future<void>>[];

      for (var i = 0; i < categories.length; i++) {
        if (i == newIndex) {
          batch.add(
            ref.read(categoryManagementProvider).updateServiceCategory(
              category.id,
              order: i,
            ),
          );
        }
        if (i != oldIndex && i != newIndex) {
          batch.add(
            ref.read(categoryManagementProvider).updateServiceCategory(
              categories[i].id,
              order: i,
            ),
          );
        }
      }

      await Future.wait(batch);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorReorderingCategories(e.toString()))),
        );
      }
    }
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, [
    ServiceCategory? category,
  ]) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CategoryDialog(category: category),
    );

    if (result != null && context.mounted) {
      try {
        final categoryManagement = ref.read(categoryManagementProvider);

        if (category == null) {
          await categoryManagement.createServiceCategory(
            name: result['name'],
            nameHe: result['nameHe'],
            order: result['order'],
          );
        } else {
          await categoryManagement.updateServiceCategory(
            category.id,
            name: result['name'],
            nameHe: result['nameHe'],
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                category == null ? l10n.categoryCreated : l10n.categoryUpdated,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceCategory category,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(categoryManagementProvider).deleteServiceCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error(e.toString()))),
          );
        }
      }
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: category.order,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(
          isHebrew ? category.nameHe : category.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: category.subCategoryIds.isNotEmpty
            ? Text(l10n.subcategories(category.subCategoryIds.length))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: category.isActive,
              onChanged: (value) {
                // Handle category status toggle
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final ServiceCategory? category;

  const _CategoryDialog({this.category});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameHeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _nameHeController = TextEditingController(text: widget.category?.nameHe);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(widget.category == null ? l10n.addCategory : l10n.editCategory),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameEnglish,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameHeController,
              decoration: InputDecoration(
                labelText: l10n.nameHebrew,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterHebrewName;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'nameHe': _nameHeController.text,
                'order': widget.category?.order ?? 999999, // High number for new categories
              });
            }
          },
          child: Text(widget.category == null ? l10n.add : l10n.save),
        ),
      ],
    );
  }
} 