import 'package:business_scheduler/features/admin/presentation/special_hours_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/opening_hours.dart';
import '../../home/providers/opening_hours_provider.dart';
import '../../home/utils/init_opening_hours.dart';
import '../../home/utils/day_localization.dart';
import '../../settings/providers/app_settings_provider.dart';
import 'special_hours_list_view.dart';
import 'package:go_router/go_router.dart';
import '../widgets/admin_app_bar.dart';
import '../../../core/widgets/firebase_index_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpeningHoursAdminView extends ConsumerStatefulWidget {
  const OpeningHoursAdminView({super.key});

  @override
  ConsumerState<OpeningHoursAdminView> createState() => _OpeningHoursAdminViewState();
}

class _OpeningHoursAdminViewState extends ConsumerState<OpeningHoursAdminView> {
  bool _isEditMode = false;

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = ref.watch(openingHoursStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return hours.when(
      data: (hours) {
        return Scaffold(
          appBar: AdminAppBar(
            backPath: '/admin',
            title: l10n.openingHoursTitle,
            actions: [
              if (_isEditMode) ...[
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddDayDialog(context),
                  tooltip: l10n.addDay,
                ),
                TextButton(
                  onPressed: _toggleEditMode,
                  child: Text(l10n.done),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => context.push('/admin/opening-hours/special'),
                  tooltip: l10n.specialHours,
                ),
                TextButton(
                  onPressed: _toggleEditMode,
                  child: Text(l10n.edit),
                ),
              ],
            ],
          ),
          body: hours.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noOpeningHours),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _initializeDefaultHours(context),
                        child: Text(l10n.initializeDefaultHours),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hours.length,
                  itemBuilder: (context, index) {
                    final hour = hours[index];
                    return _buildHourItem(hour);
                  },
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
          backPath: '/admin',
          title: l10n.openingHoursTitle,
        ),
        body: FirebaseIndexMessage(
          error: error,
          stackTrace: stack,
          onRefresh: () => ref.invalidate(openingHoursStreamProvider),
        ),
      ),
    );
  }

  Widget _buildHourItem(OpeningHours hour) {
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(DayLocalization.getLocalizedDay(context, hour.dayOfWeek)),
            subtitle: hour.isClosed
                ? Text(l10n.closed)
                : Text('${hour.openTime} - ${hour.closeTime}'),
            trailing: !_isEditMode
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, hour),
                  )
                : null,
            onTap: !_isEditMode ? () => _showEditDialog(context, hour) : null,
          ),
        ),
        if (_isEditMode)
          Positioned(
            left: -8,
            top: -8,
            child: GestureDetector(
              onTap: () => _handleDayRemoval(context, hour),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddDayDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final defaultHours = DefaultOpeningHours.defaultHours;
    final currentHours = ref.read(openingHoursStreamProvider).value ?? [];
    final startWithSunday = ref.watch(startWeekWithSundayProvider);
    
    final availableDays = defaultHours.where((defaultHour) {
      return !currentHours.any((hour) => 
        hour.dayOfWeek.toLowerCase() == defaultHour.dayOfWeek.toLowerCase() && 
        !hour.isClosed
      );
    }).toList();

    if (availableDays.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allDaysAdded)),
        );
      }
      return;
    }

    // Sort available days according to starting day setting
    availableDays.sort((a, b) {
      final orderA = DayLocalization.getDayOrder(a.dayOfWeek, startWithSunday);
      final orderB = DayLocalization.getDayOrder(b.dayOfWeek, startWithSunday);
      return orderA.compareTo(orderB);
    });

    final selectedDay = await showDialog<OpeningHours>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectDayToAdd),
        children: availableDays.map((day) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, day),
          child: Text(DayLocalization.getLocalizedDay(context, day.dayOfWeek)),
        )).toList(),
      ),
    );

    if (selectedDay == null || !context.mounted) return;

    await _showEditDialog(
      context,
      OpeningHours(
        id: selectedDay.id,
        dayOfWeek: selectedDay.dayOfWeek,
        openTime: selectedDay.openTime,
        closeTime: selectedDay.closeTime,
        isClosed: false,
        order: selectedDay.order,
      ),
    );
  }

  Future<bool?> _handleDayRemoval(BuildContext context, OpeningHours hour) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeDay(hour.dayOfWeek)),
        content: Text(l10n.removeDayMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'mark_closed'),
            child: Text(l10n.markAsClosed),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteCompletely),
          ),
        ],
      ),
    );

    if (choice == null || !context.mounted) return false;

    try {
      final service = ref.read(hoursServiceProvider);
      
      if (choice == 'mark_closed') {
        await service.updateOpeningHours(
          OpeningHours(
            id: hour.id,
            dayOfWeek: hour.dayOfWeek,
            openTime: '',
            closeTime: '',
            isClosed: true,
            order: hour.order,
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dayMarkedClosed)),
          );
        }
        return false;
      } else if (choice == 'delete') {
        await service.deleteOpeningHours(hour.dayOfWeek.toLowerCase());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dayDeleted)),
          );
        }
        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorUpdatingDay(e.toString()))),
        );
      }
    }
    return false;
  }

  Future<void> _initializeDefaultHours(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    BuildContext? dialogContext;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      await OpeningHoursInitializer.initializeOpeningHours();
      
      if (context.mounted) {
        ref.invalidate(openingHoursStreamProvider);
        
        if (dialogContext != null && dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.hoursInitialized)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (dialogContext != null && dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorInitializingHours(e.toString()))),
        );
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, OpeningHours hour) async {
    final l10n = AppLocalizations.of(context)!;
    final isClosedController = ValueNotifier<bool>(hour.isClosed);
    final openTimeController = TextEditingController(text: hour.openTime ?? '');
    final closeTimeController = TextEditingController(text: hour.closeTime ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editDay(hour.dayOfWeek)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(l10n.closed),
                  value: isClosedController.value,
                  onChanged: (value) {
                    setState(() => isClosedController.value = value);
                  },
                ),
                if (!isClosedController.value) ...[
                  TextField(
                    controller: openTimeController,
                    decoration: InputDecoration(labelText: l10n.openTime),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: closeTimeController,
                    decoration: InputDecoration(labelText: l10n.closeTime),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                final service = ref.read(hoursServiceProvider);
                await service.updateOpeningHours(
                  OpeningHours(
                    id: hour.id,
                    dayOfWeek: hour.dayOfWeek,
                    openTime: isClosedController.value ? '' : openTimeController.text,
                    closeTime: isClosedController.value ? '' : closeTimeController.text,
                    isClosed: isClosedController.value,
                    order: hour.order,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.hoursUpdated)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorUpdatingHours(e.toString()))),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    openTimeController.dispose();
    closeTimeController.dispose();
  }
} 