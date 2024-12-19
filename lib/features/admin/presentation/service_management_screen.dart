import 'package:business_scheduler/core/widgets/firebase_index_message.dart';
import 'package:business_scheduler/features/admin/widgets/admin_app_bar.dart';
import 'package:business_scheduler/features/services/models/business_service.dart';
import 'package:business_scheduler/features/services/models/service_category.dart';
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';
import 'package:business_scheduler/features/services/providers/service_categories_provider.dart';
import 'package:business_scheduler/features/services/services/category_management_service.dart';
import 'package:business_scheduler/features/services/services/default_services.dart';
import 'package:business_scheduler/features/services/services/service_management_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class _BusinessServiceCard extends ConsumerWidget {
  final BusinessService service;
  final bool showDivider;

  const _BusinessServiceCard({
    required this.service,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isHebrew ? service.nameHe : service.name,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          '${service.durationMinutes}${l10n.minutes}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₪${service.price.toStringAsFixed(2)}${service.isBasePrice == true ? '+' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (service.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isHebrew ? service.descriptionHe! : service.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: service.isActive,
                onChanged: (value) {
                  ref.read(businessServiceManagementProvider).toggleBusinessServiceStatus(
                    service.id,
                    value,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  _showBusinessServiceDialog(context, ref, service);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  _showDeleteDialog(context, ref);
                },
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1),
      ],
    );
  }

  Future<void> _showBusinessServiceDialog(BuildContext context, WidgetRef ref, BusinessService service) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _BusinessServiceDialog(service: service),
    );

    if (result != null && context.mounted) {
      try {
        await ref.read(businessServiceManagementProvider).updateBusinessService(
          service.id,
          name: result['name'],
          nameHe: result['nameHe'],
          durationMinutes: result['durationMinutes'],
          price: result['price'],
          description: result['description'],
          descriptionHe: result['descriptionHe'],
          category: result['category'],
          isBasePrice: result['isBasePrice'],
          addons: result['addons'],
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteService),
        content: Text(l10n.deleteServiceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
        await ref.read(businessServiceManagementProvider).deleteBusinessService(service.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.serviceDeleted)),
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

class _BusinessServiceDialog extends ConsumerStatefulWidget {
  final BusinessService? service;

  const _BusinessServiceDialog({this.service});

  @override
  ConsumerState<_BusinessServiceDialog> createState() => _BusinessServiceDialogState();
}

class _BusinessServiceDialogState extends ConsumerState<_BusinessServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameHeController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _descriptionHeController;
  String? _selectedCategory;
  late bool _isBasePrice;
  final List<BusinessServiceAddon> _addons = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _nameHeController = TextEditingController(text: widget.service?.nameHe);
    _durationController = TextEditingController(
      text: widget.service?.durationMinutes.toString(),
    );
    _priceController = TextEditingController(
      text: widget.service?.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.service?.description,
    );
    _descriptionHeController = TextEditingController(
      text: widget.service?.descriptionHe,
    );
    _selectedCategory = widget.service?.category;
    _isBasePrice = widget.service?.isBasePrice ?? false;
    if (widget.service?.addons != null) {
      _addons.addAll(widget.service!.addons!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHeController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _descriptionHeController.dispose();
    super.dispose();
  }

  Future<void> _addAddon() async {
    final addon = await showDialog<BusinessServiceAddon>(
      context: context,
      builder: (context) => _AddonDialog(),
    );

    if (addon != null) {
      setState(() {
        _addons.add(addon);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(serviceCategoriesProvider);

    return AlertDialog(
      title: Text(widget.service == null ? l10n.addService : l10n.editService),
      content: categories.when(
        data: (categories) {
          final activeCategories = categories.where((c) => c.isActive).toList();
          
          if (_selectedCategory == null && activeCategories.isNotEmpty) {
            _selectedCategory = activeCategories.first.id;
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                    ),
                    items: activeCategories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(isHebrew ? category.nameHe : category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.selectCategory;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: l10n.duration,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterDuration;
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return l10n.enterValidDuration;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: l10n.price,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterPrice;
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return l10n.enterValidPrice;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(l10n.startingPrice),
                    subtitle: Text(l10n.priceVaryAddons),
                    value: _isBasePrice,
                    onChanged: (value) {
                      setState(() {
                        _isBasePrice = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionEnglish,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionHeController,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionHebrew,
                    ),
                    maxLines: 2,
                  ),
                  if (_addons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.addons),
                    const SizedBox(height: 8),
                    ...List.generate(_addons.length, (index) {
                      final addon = _addons[index];
                      return ListTile(
                        title: Text(isHebrew ? addon.nameHe : addon.name),
                        subtitle: Text(
                          '${addon.durationMinutes}${l10n.minutes} • ₪${addon.price.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _addons.removeAt(index);
                            });
                          },
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addAddon,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addAddon),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.error(error.toString())),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedCategory != null) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'nameHe': _nameHeController.text,
                'durationMinutes': int.parse(_durationController.text),
                'price': double.parse(_priceController.text),
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                'descriptionHe': _descriptionHeController.text.isEmpty
                    ? null
                    : _descriptionHeController.text,
                'category': _selectedCategory,
                'isBasePrice': _isBasePrice,
                'addons': _addons.isEmpty ? null : _addons,
              });
            }
          },
          child: Text(widget.service == null ? l10n.add : l10n.save),
        ),
      ],
    );
  }
}

class _AddonDialog extends StatefulWidget {
  @override
  State<_AddonDialog> createState() => _AddonDialogState();
}

class _AddonDialogState extends State<_AddonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameHeController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionHeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nameHeController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _descriptionHeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Add-on'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (English)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameHeController,
                decoration: const InputDecoration(
                  labelText: 'Name (Hebrew)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Hebrew name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (English)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionHeController,
                decoration: const InputDecoration(
                  labelText: 'Description (Hebrew)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(BusinessServiceAddon(
                name: _nameController.text,
                nameHe: _nameHeController.text,
                durationMinutes: int.parse(_durationController.text),
                price: double.parse(_priceController.text),
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                descriptionHe: _descriptionHeController.text.isEmpty
                    ? null
                    : _descriptionHeController.text,
              ));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class BusinessServiceManagementScreen extends ConsumerStatefulWidget {
  const BusinessServiceManagementScreen({super.key});

  @override
  ConsumerState<BusinessServiceManagementScreen> createState() => _BusinessServiceManagementScreenState();
}

class _BusinessServiceManagementScreenState extends ConsumerState<BusinessServiceManagementScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkAndInitializeCategories();
  }

  Future<void> _checkAndInitializeCategories() async {
    try {
      final categoryService = ref.read(categoryManagementProvider);
      if (!await categoryService.hasCategories()) {
        if (mounted) {
          await categoryService.initializeDefaultCategories();
          // Refresh providers after initialization
          ref.invalidate(serviceCategoriesProvider);
          ref.invalidate(businessServicesProvider);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initializeDefaultServices(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.initializeConfirmTitle),
        content: Text(l10n.initializeConfirmMessage),
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
        final categoryService = ref.read(categoryManagementProvider);
        final businessService = ref.read(businessServiceManagementProvider);
        
        await categoryService.initializeDefaultCategories();
        final categories = await categoryService.getAllServiceCategories().first;
        
        await DefaultServices.initializeDefaultServices(
          businessService, 
          categories,
          categoryService,
        );
        
        ref.invalidate(serviceCategoriesProvider);
        ref.invalidate(businessServicesProvider);
        
        await Future.wait([
          ref.read(serviceCategoriesProvider.future),
          ref.read(businessServicesProvider.future),
        ]);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.servicesInitialized)),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorInitializing(error.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final categories = ref.watch(serviceCategoriesProvider);

    return categories.when(
      data: (categoriesList) {
        final services = ref.watch(businessServicesProvider);

        return services.when(
          data: (servicesList) {
            return Scaffold(
              appBar: AdminAppBar(
                title: l10n.manageServices,
                backPath: '/admin',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.category),
                    tooltip: l10n.manageCategories,
                    onPressed: () => context.push('/admin/services/categories'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: l10n.initializeDefaultServices,
                    onPressed: () => _initializeDefaultServices(context),
                  ),
                ],
              ),
              body: _buildBody(context, categoriesList, servicesList),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showBusinessServiceDialog(context, ref),
                tooltip: l10n.addNewService,
                child: const Icon(Icons.add),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Scaffold(
            appBar: AdminAppBar(
              title: l10n.manageServices,
              backPath: '/admin',
            ),
            body: FirebaseIndexMessage(
              error: error,
              stackTrace: stack,
              onRefresh: () => ref.invalidate(businessServicesProvider),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AdminAppBar(
          title: l10n.manageServices,
          backPath: '/admin',
        ),
        body: FirebaseIndexMessage(
          error: error,
          stackTrace: stack,
          onRefresh: () => ref.invalidate(serviceCategoriesProvider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ServiceCategory> categoriesList, List<BusinessService> servicesList) {
    final l10n = AppLocalizations.of(context)!;
    
    if (servicesList.isEmpty || categoriesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.spa_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              categoriesList.isEmpty
                  ? l10n.noCategories
                  : l10n.noServices,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _initializeDefaultServices(context),
              icon: const Icon(Icons.restore),
              label: Text(l10n.initializeDefaultServices),
            ),
          ],
        ),
      );
    }

    final groupedServices = <String, List<BusinessService>>{};
    for (final category in categoriesList) {
      if (category.isActive) {
        groupedServices[category.id] = servicesList
            .where((service) => service.category == category.id)
            .toList();
      }
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: categoriesList.length,
      itemBuilder: (context, index) {
        final category = categoriesList[index];
        if (!category.isActive) return const SizedBox.shrink();
        
        final categoryServices = groupedServices[category.id] ?? [];
        if (categoryServices.isEmpty) return const SizedBox.shrink();

        final isHebrew = Localizations.localeOf(context).languageCode == 'he';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                isHebrew ? category.nameHe : category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...categoryServices.asMap().entries.map((entry) {
              final isLast = entry.key == categoryServices.length - 1;
              return _BusinessServiceCard(
                service: entry.value,
                showDivider: !isLast,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Future<void> _showBusinessServiceDialog(BuildContext context, WidgetRef ref, [BusinessService? service]) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _BusinessServiceDialog(service: service),
    );

    if (result != null && context.mounted) {
      try {
        final serviceManagement = ref.read(businessServiceManagementProvider);
        
        if (service == null) {
          await serviceManagement.createBusinessService(
            name: result['name'],
            nameHe: result['nameHe'],
            durationMinutes: result['durationMinutes'],
            price: result['price'],
            category: result['category'],
            isBasePrice: result['isBasePrice'],
            addons: result['addons'],
            description: result['description'],
            descriptionHe: result['descriptionHe'],
          );
        } else {
          await serviceManagement.updateBusinessService(
            service.id,
            name: result['name'],
            nameHe: result['nameHe'],
            durationMinutes: result['durationMinutes'],
            price: result['price'],
            category: result['category'],
            isBasePrice: result['isBasePrice'],
            addons: result['addons'],
            description: result['description'],
            descriptionHe: result['descriptionHe'],
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(service == null ? l10n.serviceCreated : l10n.serviceUpdated),
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
} 