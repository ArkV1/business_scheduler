import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models/business_service.dart';
import '../../services/models/service_category.dart';
import '../../services/providers/service_categories_provider.dart';
import '../../../core/widgets/firebase_index_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesTabView extends ConsumerStatefulWidget {
  final List<BusinessService> services;

  const ServicesTabView({
    super.key,
    required this.services,
  });

  @override
  ConsumerState<ServicesTabView> createState() => _ServicesTabViewState();
}

class _ServicesTabViewState extends ConsumerState<ServicesTabView> {
  List<ServiceCategory> _categories = [];
  Map<String, List<BusinessService>> _servicesByCategory = {};
  String? _selectedCategoryId;

  void _updateCategories(List<ServiceCategory> categories) {
    // Group services by category
    final newServicesByCategory = <String, List<BusinessService>>{};
    for (final service in widget.services) {
      if (service.isActive) {
        newServicesByCategory.putIfAbsent(service.category, () => []);
        newServicesByCategory[service.category]!.add(service);
      }
    }

    // Filter categories that have services and are active
    final newCategories = categories
        .where((category) => 
            category.isActive && 
            newServicesByCategory.containsKey(category.id))
        .toList();

    setState(() {
      _categories = newCategories;
      _servicesByCategory = newServicesByCategory;
      if (_selectedCategoryId == null && newCategories.isNotEmpty) {
        _selectedCategoryId = newCategories.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final categories = ref.watch(serviceCategoriesProvider);

    return categories.when(
      data: (categoriesList) {
        _updateCategories(categoriesList);

        if (_categories.isEmpty) {
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
                  'No services available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category.id == _selectedCategoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          isHebrew ? category.nameHe : category.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedCategoryId != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _servicesByCategory[_selectedCategoryId]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final service = _servicesByCategory[_selectedCategoryId]![index];
                    return _ServiceCard(service: service);
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => FirebaseIndexMessage(
        error: error,
        stackTrace: stack,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final BusinessService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isHebrew ? service.nameHe : service.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${service.durationMinutes}min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₪${service.price.toStringAsFixed(2)}${service.isBasePrice ?? false ? '+' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (service.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isHebrew ? service.descriptionHe! : service.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 