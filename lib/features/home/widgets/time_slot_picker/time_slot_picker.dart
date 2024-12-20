import 'package:business_scheduler/features/appointments/providers/appointment_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/models/business_service.dart';
import '../../../services/models/service_category.dart';
import '../../../services/providers/service_categories_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:business_scheduler/features/appointments/models/time_slot_section.dart';

import 'package:business_scheduler/features/appointments/providers/appointment_availability_provider.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_state_provider.dart';
import 'package:business_scheduler/features/appointments/services/appointment_service.dart';

class TimeSlotPicker extends ConsumerStatefulWidget {
  final List<BusinessService> services;
  final List<String> timeSlots;
  final DateTime selectedDate;
  final VoidCallback? onConfirm;

  const TimeSlotPicker({
    super.key,
    required this.services,
    required this.timeSlots,
    required this.selectedDate,
    this.onConfirm,
  });

  @override
  ConsumerState<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends ConsumerState<TimeSlotPicker>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<ServiceCategory> _categories = [];
  Map<String, List<BusinessService>> _servicesByCategory = {};

  String calculateEndTime(String startTime, int durationMinutes) {
    // Parse the start time (format: "HH:mm")
    final parts = startTime.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);

    // Create a DateTime object for calculation
    final startDateTime = DateTime(2022, 1, 1, startHour, startMinute);
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

    // Format the end time
    return '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _categories = [];
    _servicesByCategory = {};
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

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

    if (newCategories.length != _categories.length) {
      setState(() {
        _categories = newCategories;
        _servicesByCategory = newServicesByCategory;
        
        _tabController?.dispose();
        _tabController = TabController(
          length: newCategories.length,
          vsync: this,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(serviceCategoriesProvider);
    final selectedService = ref.watch(selectedServiceProvider);

    return categories.when(
      data: (categoriesList) {
        _updateCategories(categoriesList);

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      l10n.selectServiceAndTime,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Service categories
            if (_categories.isNotEmpty) ...[
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _categories.map((category) {
                  final isHebrew = Localizations.localeOf(context).languageCode == 'he';
                  return Tab(text: isHebrew ? category.nameHe : category.name);
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: TabBarView(
                  controller: _tabController,
                  children: _categories.map((category) {
                    final services = _servicesByCategory[category.id] ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isSelected = selectedService?.id == service.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ServiceCard(
                            service: service,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedServiceProvider.notifier).state = service;
                              ref.read(selectedTimeSlotProvider.notifier).state = null;
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.spa_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noServicesAvailable,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Time slots
            if (selectedService != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 20, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          l10n.availableTimeSlots,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('EEE, MMM d').format(widget.selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _getTimeSlotSections().length,
                  itemBuilder: (context, sectionIndex) {
                    final section = _getTimeSlotSections()[sectionIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            section.displayHour,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: section.slots.map((timeSlot) {
                            final isSelected = timeSlot == ref.watch(selectedTimeSlotProvider);
                            final isAvailable = ref.watch(timeSlotAvailabilityProvider(
                              (date: widget.selectedDate, timeSlot: timeSlot, service: selectedService)
                            )).when(
                              data: (available) => available,
                              loading: () => false,
                              error: (_, __) => false,
                            );

                            final endTime = calculateEndTime(timeSlot, selectedService.durationMinutes);

                            return SizedBox(
                              width: 80,
                              height: 44,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isAvailable ? () {
                                    ref.read(selectedTimeSlotProvider.notifier).state = timeSlot;
                                  } : null,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? theme.primaryColor.withOpacity(0.1) :
                                             !isAvailable ? Colors.grey[100] : null,
                                      border: Border.all(
                                        color: isSelected ? theme.primaryColor :
                                               !isAvailable ? Colors.grey[300]! : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          timeSlot,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isSelected ? theme.primaryColor :
                                                   !isAvailable ? Colors.grey : null,
                                            fontWeight: isSelected ? FontWeight.bold : null,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (isAvailable) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            endTime,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (sectionIndex < _getTimeSlotSections().length - 1)
                          const Divider(height: 24),
                      ],
                    );
                  },
                ),
              ),

              // Confirm button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: ref.watch(selectedTimeSlotProvider) != null ? () {
                    widget.onConfirm?.call();
                  } : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.confirm),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading services: $error'),
      ),
    );
  }

  List<TimeSlotSection> _getTimeSlotSections() {
    final appointmentService = ref.read(appointmentServiceProvider);
    return appointmentService.groupTimeSlots(widget.timeSlots);
  }
}

class ServiceCard extends StatelessWidget {
  final BusinessService service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHebrew ? service.nameHe : service.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected ? theme.primaryColor : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                '${service.durationMinutes} ${l10n.minutes} • \$${service.price}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
