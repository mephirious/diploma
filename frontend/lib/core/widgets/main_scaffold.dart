import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../features/venues/presentation/pages/home_page.dart';
import '../../features/reservations/presentation/pages/reservations_page.dart';
import '../../features/sessions/presentation/pages/sessions_list_page.dart';
import '../../features/chats/presentation/pages/chats_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chats/presentation/providers/chats_provider.dart';
import '../../features/owner/presentation/pages/owner_analytics_page.dart';
import '../../features/owner/presentation/pages/owner_bookings_page.dart';
import '../../features/owner/presentation/pages/owner_home_page.dart';
import '../../features/reservations/presentation/providers/reservations_provider.dart';
import '../../features/sessions/presentation/providers/sessions_provider.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        ref.read(chatControllerProvider.notifier).onUserAuthenticated();
      } else if (next.status == AuthStatus.unauthenticated) {
        ref.read(chatControllerProvider.notifier).onLogout();
      }
    });

    final selectedIndex = ref.watch(selectedIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = ref.watch(totalUnreadCountProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isOwner = isAuthenticated && (authState.authUser?.isOwner ?? false);

    final pages = isOwner
        ? const [
            OwnerHomePage(),
            OwnerBookingsPage(),
            OwnerAnalyticsPage(),
            ChatsPage(),
            ProfilePage(),
          ]
        : const [
            HomePage(),
            ReservationsPage(),
            SessionsPage(),
            ChatsPage(),
            ProfilePage(),
          ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
          if (!isOwner && index == 1) {
            resetGuestBookingLists(ref);
          }
          if (!isOwner && index == 2) {
            unawaited(
              ref.read(sessionsListProvider.notifier).ensureLoaded(),
            );
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              isOwner ? Icons.business_outlined : Icons.sports_soccer_outlined,
            ),
            selectedIcon: Icon(
              isOwner ? Icons.business : Icons.sports_soccer,
            ),
            label: isOwner ? l10n.manageTab : l10n.facilitiesTab,
          ),
          NavigationDestination(
            icon: Icon(
              isOwner
                  ? Icons.dashboard_customize_outlined
                  : Icons.calendar_today_outlined,
            ),
            selectedIcon: Icon(
              isOwner ? Icons.dashboard_customize : Icons.calendar_today,
            ),
            label: isOwner ? l10n.dashboardTab : l10n.bookingsTab,
          ),
          NavigationDestination(
            icon: Icon(
              isOwner ? Icons.bar_chart_outlined : Icons.groups_outlined,
            ),
            selectedIcon: Icon(
              isOwner ? Icons.bar_chart : Icons.groups,
            ),
            label: isOwner ? l10n.analyticsTab : l10n.sessions,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString()),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString()),
              child: const Icon(Icons.chat_bubble),
            ),
            label: l10n.chats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
