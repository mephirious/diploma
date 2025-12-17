import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/venues/presentation/pages/venues_list_page.dart';
import '../../features/venues/presentation/pages/venue_detail_page.dart';
import '../../features/sessions/presentation/pages/sessions_list_page.dart';
import '../../features/reservations/presentation/pages/reservations_list_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/venues';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/venues',
        builder: (context, state) => const VenuesListPage(),
      ),
      GoRoute(
        path: '/venues/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VenueDetailPage(venueId: id);
        },
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionsListPage(),
      ),
      GoRoute(
        path: '/reservations',
        builder: (context, state) => const ReservationsListPage(),
      ),
    ],
  );
});

