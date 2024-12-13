import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appointment_app/core/providers/locale_provider.dart';
import 'package:appointment_app/features/auth/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authStateChangesProvider);
    final isLoggedIn = authState.value != null;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 304,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.2),
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.zero,
                  child: DrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              'LÍRAMOR',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              'BEAUTY & GLAM',
                              style: theme.textTheme.titleMedium?.copyWith(
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isAdmin) ...[
                  Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  ClipRect(
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        leading: Icon(Icons.admin_panel_settings, color: theme.iconTheme.color),
                        title: Text(
                          l10n.adminDashboard,
                          style: theme.textTheme.bodyLarge,
                        ),
                        onTap: () {
                          context.go('/admin');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
                ClipRect(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.language, color: theme.iconTheme.color),
                      title: Text(
                        l10n.language,
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: Text(
                        locale.languageCode == 'en' ? l10n.english : l10n.hebrew,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => ref.read(localeControllerProvider.notifier).toggleLocale(),
                    ),
                  ),
                ),
                ClipRect(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.settings, color: theme.iconTheme.color),
                      title: Text(
                        l10n.settings,
                        style: theme.textTheme.bodyLarge,
                      ),
                      onTap: () {
                        context.go('/settings');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
                ClipRect(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.home, color: theme.iconTheme.color),
                      title: Text(
                        l10n.home,
                        style: theme.textTheme.bodyLarge,
                      ),
                      onTap: () {
                        context.go('/');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
                ClipRect(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(
                        isLoggedIn ? Icons.logout : Icons.login,
                        color: theme.iconTheme.color,
                      ),
                      title: Text(
                        isLoggedIn ? l10n.logout : l10n.login,
                        style: theme.textTheme.bodyLarge,
                      ),
                      onTap: () async {
                        if (isLoggedIn) {
                          await ref.read(authProvider).signOut();
                          if (context.mounted) {
                            context.go('/');
                            Navigator.pop(context);
                          }
                        } else {
                          context.go('/login');
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}