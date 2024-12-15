import 'package:appointment_app/features/admin/presentation/gallery_screen.dart';
import 'package:appointment_app/features/home/models/opening_hours.dart';
import 'package:appointment_app/features/services/models/business_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mix/mix.dart' hide $token;
import 'package:appointment_app/design/tokens/tokens.dart';
import '../widgets/calendar/calendar.dart';
import '../widgets/service_card.dart';
import '../widgets/services_tab_view.dart';
import '../widgets/quick_action_card/quick_action_card.dart';
import '../widgets/social_links.dart';
import '../widgets/expandable_info_button/expandable_info_button.dart';
import '../widgets/opening_hours_display.dart';
import '../providers/selected_tab_provider.dart';
import '../providers/opening_hours_provider.dart';
import '../providers/social_links_provider.dart';
import '../../services/providers/business_services_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedTab = ref.watch(selectedTabProvider);
    final openingHoursAsync = ref.watch(openingHoursStreamProvider);
    final servicesAsync = ref.watch(businessServicesProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Section
          Container(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
            child: const Calendar(
              id: 'home_calendar',
            ),
          ),
          
          // Info Buttons Section with Shared Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                
                if (isSmallScreen) {
                  return Column(
                    children: [
                      // Services Button - Full Width at top
                      ExpandableInfoButton(
                        title: l10n.services,
                        icon: Icons.spa,
                        isSelected: selectedTab == 1,
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = 
                              selectedTab == 1 ? null : 1;
                        },
                        expandedContent: Consumer(
                          builder: (context, ref, child) {
                            final servicesAsync = ref.watch(businessServicesProvider);
                            return servicesAsync.when(
                              data: (services) {
                                if (services.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.spa_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noServicesAvailable,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ServicesTabView(services: services);
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Opening Hours and Gallery Buttons Row below
                      Row(
                        children: [
                          Expanded(
                            child: ExpandableInfoButton(
                              title: l10n.openingHours,
                              icon: Icons.access_time,
                              isSelected: selectedTab == 0,
                              onTap: () {
                                ref.read(selectedTabProvider.notifier).state = 
                                    selectedTab == 0 ? null : 0;
                              },
                              expandedContent: Consumer(
                                builder: (context, ref, child) {
                                  final openingHoursAsync = ref.watch(openingHoursStreamProvider);
                                  return openingHoursAsync.when(
                                    data: (hours) {
                                      if (hours.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.access_time_outlined,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                l10n.noOpeningHoursAvailable,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return OpeningHoursDisplay(
                                        hours: hours,
                                        showTitle: false,
                                        showToday: true,
                                      );
                                    },
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (error, stack) => Text('Error: $error'),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ExpandableInfoButton(
                              title: l10n.gallery,
                              icon: Icons.photo_library,
                              isSelected: selectedTab == 2,
                              onTap: () {
                                ref.read(selectedTabProvider.notifier).state = 
                                    selectedTab == 2 ? null : 2;
                              },
                              expandedContent: Consumer(
                                builder: (context, ref, child) {
                                  final galleryAsync = ref.watch(galleryImagesProvider);
                                  return galleryAsync.when(
                                    data: (images) {
                                      if (images.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.photo_library_outlined,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                l10n.noGalleryAvailable,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: images.length,
                                        itemBuilder: (context, index) {
                                          final image = images[index];
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: image.assetPath != null
                                                ? Image.asset(
                                                    image.assetPath!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    image.url,
                                                    fit: BoxFit.cover,
                                                  ),
                                          );
                                        },
                                      );
                                    },
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (error, stack) => Text('Error: $error'),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Original layout for larger screens
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ExpandableInfoButton(
                        title: l10n.openingHours,
                        icon: Icons.access_time,
                        isSelected: selectedTab == 0,
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = 
                              selectedTab == 0 ? null : 0;
                        },
                        expandedContent: Consumer(
                          builder: (context, ref, child) {
                            final openingHoursAsync = ref.watch(openingHoursStreamProvider);
                            return openingHoursAsync.when(
                              data: (hours) {
                                if (hours.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noOpeningHoursAvailable,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return OpeningHoursDisplay(
                                  hours: hours,
                                  showTitle: false,
                                  showToday: true,
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ExpandableInfoButton(
                        title: l10n.services,
                        icon: Icons.spa,
                        isSelected: selectedTab == 1,
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = 
                              selectedTab == 1 ? null : 1;
                        },
                        expandedContent: Consumer(
                          builder: (context, ref, child) {
                            final servicesAsync = ref.watch(businessServicesProvider);
                            return servicesAsync.when(
                              data: (services) {
                                if (services.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.spa_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noServicesAvailable,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ServicesTabView(services: services);
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ExpandableInfoButton(
                        title: l10n.gallery,
                        icon: Icons.photo_library,
                        isSelected: selectedTab == 2,
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = 
                              selectedTab == 2 ? null : 2;
                        },
                        expandedContent: Consumer(
                          builder: (context, ref, child) {
                            final galleryAsync = ref.watch(galleryImagesProvider);
                            return galleryAsync.when(
                              data: (images) {
                                if (images.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_library_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noGalleryAvailable,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    final image = images[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: image.assetPath != null
                                          ? Image.asset(
                                              image.assetPath!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              image.url,
                                              fit: BoxFit.cover,
                                            ),
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: selectedTab != null
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            ),
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        key: ValueKey<int>(selectedTab),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          minHeight: 80,
                          maxHeight: selectedTab == 1 ? 280 : 320,
                        ),
                        child: selectedTab == 1
                            ? servicesAsync.when(
                                data: (services) {
                                  if (services.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.spa_outlined,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            l10n.noServicesAvailable,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return ServicesTabView(services: services);
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, stack) => Text('Error: $error'),
                              )
                            : SingleChildScrollView(
                                child: _buildTabContent(context, selectedTab, openingHoursAsync, servicesAsync),
                              ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              height: 0,
              thickness: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                QuickActionCard(
                  icon: Icons.access_time,
                  label: l10n.myAppointments,
                  color: Theme.of(context).primaryColor,
                  onTap: () => context.push('/appointments'),
                ),
                const SizedBox(height: 12),
                QuickActionCard(
                  icon: Icons.calendar_today,
                  label: l10n.bookAppointment,
                  color: Theme.of(context).primaryColor,
                  onTap: () => context.pushNamed('booking'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Social Links Section
          Consumer(
            builder: (context, ref, child) {
              final socialLinksAsync = ref.watch(socialLinksStreamProvider);
              return socialLinksAsync.when(
                data: (socialLinks) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SocialLinks(socialLinks: socialLinks),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, int selectedTab, AsyncValue<List<OpeningHours>> openingHoursAsync, AsyncValue<List<BusinessService>> servicesAsync) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (selectedTab) {
      case 0:
        return openingHoursAsync.when(
          data: (hours) {
            if (hours.isEmpty) {
              return _buildEmptyState(
                context,
                Icons.access_time_outlined,
                l10n.noOpeningHoursAvailable,
              );
            }
            return OpeningHoursDisplay(
              hours: hours,
              showTitle: false,
              showToday: true,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      case 1:
        return servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return _buildEmptyState(
                context,
                Icons.spa_outlined,
                l10n.noServicesAvailable,
              );
            }
            return ServicesTabView(services: services);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      case 2:
        return Consumer(
          builder: (context, ref, child) {
            final galleryAsync = ref.watch(galleryImagesProvider);
            return galleryAsync.when(
              data: (images) {
                if (images.isEmpty) {
                  return _buildEmptyState(
                    context,
                    Icons.photo_library_outlined,
                    l10n.noGalleryAvailable,
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image.assetPath != null
                          ? Image.asset(
                              image.assetPath!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              image.url,
                              fit: BoxFit.cover,
                            ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}