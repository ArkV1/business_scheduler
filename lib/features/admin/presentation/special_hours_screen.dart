import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/models/special_hours.dart';
import '../../home/providers/opening_hours_provider.dart';
import '../widgets/admin_app_bar.dart';
import '../../home/utils/day_localization.dart';
import '../../settings/presentation/app_settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SpecialHoursListView extends ConsumerWidget {
  const SpecialHoursListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialHours = ref.watch(specialHoursStreamProvider);

    return Scaffold(
      appBar: AdminAppBar(
        title: 'Special Hours',
        backPath: '/admin/opening-hours',
      ),
      body: specialHours.when(
        data: (hours) {
          if (hours.isEmpty) {
            return const Center(
              child: Text('No special hours set'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              return Card(
                child: ListTile(
                  title: Text(hour.date.toString().split(' ')[0]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hour.isClosed)
                        const Text('Closed')
                      else
                        Text('${hour.openTime} - ${hour.closeTime}'),
                      if (hour.note?.isNotEmpty ?? false)
                        Text(
                          hour.note!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to remove these special hours?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true || !context.mounted) return;

                      try {
                        final service = ref.read(hoursServiceProvider);
                        await service.deleteSpecialHours(hour.date);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Special hours removed successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error removing special hours: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSpecialHoursDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddSpecialHoursDialog(BuildContext context, WidgetRef ref) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null || !context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        final isClosedController = ValueNotifier<bool>(false);
        final openTimeController = TextEditingController();
        final closeTimeController = TextEditingController();
        final noteController = TextEditingController();

        return AlertDialog(
          title: Text('Special Hours for ${selectedDate.toString().split(' ')[0]}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Closed'),
                      value: isClosedController.value,
                      onChanged: (value) {
                        setState(() => isClosedController.value = value);
                      },
                    ),
                    if (!isClosedController.value) ...[
                      TextField(
                        controller: openTimeController,
                        decoration: const InputDecoration(labelText: 'Open Time'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: closeTimeController,
                        decoration: const InputDecoration(labelText: 'Close Time'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Note (Optional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final service = ref.read(hoursServiceProvider);
                  await service.addSpecialHours(
                    SpecialHours(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      date: selectedDate,
                      isClosed: isClosedController.value,
                      openTime: openTimeController.text,
                      closeTime: closeTimeController.text,
                      note: noteController.text,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Special hours added successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding special hours: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
} 