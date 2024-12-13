import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(l10n.notLoggedIn),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(l10n.fullName),
                      subtitle: Text(user.fullName),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(l10n.email),
                      subtitle: Text(user.email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(l10n.phoneNumber),
                      subtitle: user.phoneNumber != null
                          ? Text(user.phoneNumber!)
                          : Text(
                              l10n.phoneNumberNotSet,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                      trailing: user.phoneNumber == null
                          ? IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => context.go('/profile/edit'),
                              tooltip: l10n.addPhoneNumber,
                            )
                          : null,
                    ),
                    if (isAdmin) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined),
                        title: Text(l10n.adminStatus),
                        subtitle: Text(l10n.administrator),
                        trailing: IconButton(
                          icon: const Icon(Icons.dashboard_outlined),
                          onPressed: () => context.go('/admin'),
                          tooltip: l10n.adminDashboard,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.go('/profile/edit');
              },
              icon: const Icon(Icons.edit),
              label: Text(l10n.editProfile),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final authService = ref.read(authProvider);
                await authService.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
} 