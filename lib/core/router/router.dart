import 'package:appointment_app/features/admin/presentation/category_management_screen.dart';
import 'package:appointment_app/features/admin/presentation/service_management_screen.dart';
import 'package:appointment_app/features/admin/presentation/special_hours_screen.dart';
import 'package:appointment_app/features/appointments/views/admin_appointments_view.dart';
import 'package:appointment_app/features/appointments/presentation/booking_view.dart';
import 'package:appointment_app/features/settings/presentation/user_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/shell/presentation/main_layout.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/appointments/presentation/appointments_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/providers/user_provider.dart';
import '../../features/admin/presentation/opening_hours_admin_view.dart';
import '../../features/admin/presentation/gallery_screen.dart';
import '../../features/admin/presentation/social_links_screen.dart';
import '../../features/admin/presentation/special_hours_list_view.dart';
import '../../features/settings/presentation/app_settings_screen.dart';
import 'page_transitions.dart';
import 'package:appointment_app/features/auth/presentation/profile_screen.dart';
import 'package:appointment_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:appointment_app/features/auth/presentation/edit_profile_screen.dart';


extension GoRouterLocation on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

    // Add new helper method
  bool isCurrentRoute(String route) {
    final currentLocation = location;
    // Remove any query parameters for comparison
    final strippedLocation = currentLocation.split('?').first;
    // Ensure routes start with forward slash
    final normalizedRoute = route.startsWith('/') ? route : '/$route';
    return strippedLocation == normalizedRoute;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isProtectedRoute = state.matchedLocation == '/appointments' || 
                              state.matchedLocation == '/booking';

      // If logged in but on auth pages, redirect to home
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }

      // If trying to access protected routes but not logged in, redirect to login
      if (!isLoggedIn && isProtectedRoute) {
        return '/login';
      }

      // If trying to access admin route but not admin, redirect to home
      if (isAdminRoute && !isAdmin) {
        return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => FadeThroughTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/booking',
            name: 'booking',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const BookingView(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const LoginScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/register',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const RegisterScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/forgot-password',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const ForgotPasswordScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const AppointmentsScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) => FadeThroughTransitionPage(
              child: const AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/services',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const BusinessServiceManagementScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/appointments',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const AdminAppointmentsView(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/services/categories',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const CategoryManagementScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/opening-hours',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const OpeningHoursAdminView(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/gallery',
            pageBuilder: (context, state) => OpenContainerTransitionPage(
              child: const GalleryAdminView(),
            ),
          ),
          GoRoute(
            path: '/admin/social-links',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const SocialLinksAdminView(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/opening-hours/special',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const SpecialHoursListView(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/admin/settings',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const AppSettingsScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              child: const UserSettingsScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => SharedAxisTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => SharedAxisTransitionPage(
                  key: state.pageKey,
                  child: const EditProfileScreen(),
                  transitionType: SharedAxisTransitionType.vertical,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});