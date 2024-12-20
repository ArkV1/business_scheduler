import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (!isAdmin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.adminNoAccess),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: Text(l10n.goHome),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          l10n.businessManagement,
          [
            _AdminTile(
              title: l10n.servicesTitle,
              subtitle: l10n.servicesSubtitle,
              icon: Icons.spa,
              color: Colors.blue,
              onTap: () => context.go('/admin/services'),
            ),
            _AdminTile(
              title: l10n.openingHoursTitle,
              subtitle: l10n.openingHoursSubtitle,
              icon: Icons.access_time,
              color: Colors.green,
              onTap: () => context.go('/admin/opening-hours'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          l10n.appointmentsManagement,
          [
            _AdminTile(
              title: l10n.manageAppointments,
              subtitle: l10n.appointmentsManagementSubtitle,
              icon: Icons.calendar_today,
              color: Colors.indigo,
              onTap: () => context.go('/admin/appointments'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          l10n.contentManagement,
          [
            _AdminTile(
              title: l10n.galleryTitle,
              subtitle: l10n.gallerySubtitle,
              icon: Icons.photo_library,
              color: Colors.purple,
              onTap: () => context.go('/admin/gallery'),
            ),
            _AdminTile(
              title: l10n.socialLinksTitle,
              subtitle: l10n.socialLinksSubtitle,
              icon: Icons.link,
              color: Colors.orange,
              onTap: () => context.go('/admin/social-links'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          l10n.systemSettings,
          [
            _AdminTile(
              title: l10n.appSettingsTitle,
              subtitle: l10n.appSettingsSubtitle,
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => context.go('/admin/settings'),
              disabled: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _AdminTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const _AdminTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledOpacity = 0.5;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: disabled ? disabledOpacity : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!disabled) Icon(
                  Icons.chevron_right,
                  color: theme.dividerColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}