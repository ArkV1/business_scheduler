import 'package:business_scheduler/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart' hide $token;
import 'package:business_scheduler/design/tokens/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:business_scheduler/features/shell/widgets/app_drawer.dart';
import 'package:business_scheduler/features/auth/providers/user_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  String _getTitle(BuildContext context, GoRouter router) {
    final l10n = AppLocalizations.of(context)!;
    final location = router.location;
    
    // Admin routes
    if (location.startsWith('/admin')) {
      if (location == '/admin') return l10n.adminDashboard;
      if (location == '/admin/opening-hours') return l10n.openingHours;
      if (location == '/admin/services') return l10n.services;
      if (location == '/admin/gallery') return l10n.gallery;
      if (location == '/admin/social-links') return l10n.socialLinks;
      if (location == '/admin/settings') return l10n.adminSettings;
      return l10n.admin;
    }
    
    // Main routes
    if (location == '/') return l10n.home;
    if (location == '/appointments') return l10n.myAppointments;
    if (location == '/login') return l10n.login;
    if (location == '/register') return l10n.register;
    if (location == '/settings') return l10n.settings;
    if (location == '/profile') return l10n.profile;
    
    return l10n.appointmentBooking;
  }

  Widget _buildTitle(BuildContext context, GoRouter router, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final location = router.location;

    // Show logo on home screen
    if (location == '/') {
      return SizedBox(
        height: 68,  // Fixed height for the logo container
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'LÍRAMOR',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'BEAUTY & GLAM',
                      style: theme.textTheme.titleMedium?.copyWith(
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Return regular title for other routes
    return SizedBox(
      height: 40,  // Fixed height for regular title
      child: Center(
        child: StyledText(
          _getTitle(context, router),
          style: Style(
            $text.style.ref($token.textStyle.displaySmall),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    final router = GoRouter.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        drawerScrimColor: Colors.black12,
        body: Box(
          style: Style(
            $box.color.ref($token.color.background),
            $box.height(double.infinity),
          ),
          child: Column(
            children: [
              // App Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: router.location == '/' ? 100 : 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Box(
                  style: Style(
                    $box.padding.vertical(16),
                    $box.padding.horizontal(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu),
                        ),
                      ),
                      Expanded(
                        child: ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildTitle(context, router, theme),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (user == null && !router.isCurrentRoute('/login')) {
                            context.push('/login');
                          } else if (user != null && !router.isCurrentRoute('/profile')) {
                            context.push('/profile');
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 20,
                          child: Icon(
                            user != null ? Icons.account_circle : Icons.person_outline,
                            size: 30,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}