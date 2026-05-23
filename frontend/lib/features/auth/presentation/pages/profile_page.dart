import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../../core/widgets/app_main_app_bar.dart';
import '../../../../core/widgets/auth_required_screen.dart';
import '../providers/auth_provider.dart';
import '../../../venues/presentation/providers/venue_provider.dart';
import '../../../venues/presentation/providers/saved_cards_provider.dart';
import '../../../venues/presentation/widgets/venue_card.dart';
import '../../../venues/presentation/pages/venue_detail_page.dart';
import '../../../owner/data/owner_mock_data.dart';
import '../../../reservations/presentation/providers/reservations_provider.dart';

class _NotificationsNotifier extends StateNotifier<bool> {
  static const _key = 'account.notifications.enabled';

  _NotificationsNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<_NotificationsNotifier, bool>((ref) {
  return _NotificationsNotifier();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  ProviderSubscription<int>? _tabIndexSub;

  @override
  void initState() {
    super.initState();
    _tabIndexSub = ref.listenManual<int>(
      selectedIndexProvider,
      (previous, next) {
        if (previous == next || next != 4) return;
        unawaited(ref.read(authProvider.notifier).checkAuthStatus());
      },
    );
  }

  @override
  void dispose() {
    _tabIndexSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    if (!isLoggedIn) {
      return AuthRequiredScreen(
        title: l10n.profile,
        description: 'Login or register to view your profile.',
      );
    }

    final user = authState.user;
    final isOwner = authState.authUser?.isOwner ?? false;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.appBarDarkGradient
              : AppColors.appBarGradient,
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                // This covers the entire scrollable area with normal bg color
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                    children: [
                      // Profile Header – full bleed to top, covers status bar
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              24,
                              MediaQuery.of(context).padding.top + 24,
                              24,
                              40,
                            ),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.appBarDarkGradient
                                  : AppColors.appBarGradient,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    (user?.fullName.isNotEmpty == true
                                            ? user!.fullName.substring(0, 1).toUpperCase()
                                            : 'U'),
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.colorMain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  user?.fullName ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Liquid glass edit button floating top-right
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            right: 16,
                            child: LiquidGlassIconButton(
                              margin: EdgeInsets.zero,
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 18),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      // Personal Info – overlaps header slightly for seamless look
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 2,
                            shadowColor:
                                Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                children: [
                                  _profileListTile(
                                    context,
                                    icon: Icons.person_outline,
                                    title: l10n.fullName,
                                    subtitle: user?.fullName ?? '',
                                    isDark: isDark,
                                  ),
                                  Divider(
                                      height: 1,
                                      color:
                                          isDark ? Colors.grey[800] : Colors.grey[200]),
                                  _profileListTile(
                                    context,
                                    icon: Icons.email_outlined,
                                    title: l10n.email,
                                    subtitle: user?.email ?? '',
                                    isDark: isDark,
                                  ),
                                  Divider(
                                      height: 1,
                                      color:
                                          isDark ? Colors.grey[800] : Colors.grey[200]),
                                  _profileListTile(
                                    context,
                                    icon: Icons.phone_outlined,
                                    title: l10n.phone,
                                    subtitle: user?.phone ?? '',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (isOwner)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.colorMain
                                              .withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.verified_user_outlined,
                                          color: AppColors.colorMain,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        l10n.ownerPublicProfile,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ownerMetric(
                                          context,
                                          label: l10n.hostReviews,
                                          value: '4.9',
                                          icon: Icons.star_rounded,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _ownerMetric(
                                          context,
                                          label: l10n.responseRate,
                                          value: '96%',
                                          icon: Icons.bolt,
                                          color: AppColors.colorSuccess,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _ownerMetric(
                                          context,
                                          label: l10n.memberSince,
                                          value: '2021',
                                          icon: Icons.calendar_today,
                                          color: AppColors.colorInfo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (isOwner) const SizedBox(height: 24),

                      // My Bookings & Favorites
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorMain.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.calendar_today,
                                      color: AppColors.colorMain, size: 20),
                                ),
                                title: Text(
                                    isOwner ? l10n.bookingsDashboard : l10n.myBookings,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.w600)),
                                trailing: Icon(Icons.chevron_right,
                                    color:
                                        isDark ? Colors.grey[600] : Colors.grey[400]),
                                onTap: () {
                                  if (!isOwner) {
                                    resetGuestBookingLists(ref);
                                  }
                                  ref.read(selectedIndexProvider.notifier).state =
                                      1;
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
                              ),
                              Divider(
                                  height: 1,
                                  indent: 56,
                                  endIndent: 16,
                                  color: isDark ? Colors.grey[800] : Colors.grey[200]),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.favorite,
                                      color: Colors.redAccent, size: 20),
                                ),
                                title: Text(
                                    isOwner ? l10n.myFacilities : l10n.myFavorites,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.w600)),
                                trailing: Icon(Icons.chevron_right,
                                    color:
                                        isDark ? Colors.grey[600] : Colors.grey[400]),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => isOwner
                                          ? const _FacilitiesSubPage()
                                          : const _FavoritesSubPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Settings Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                l10n.settings,
                                style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  _settingsTile(
                                    context,
                                    icon: Icons.language,
                                    title: l10n.language,
                                    subtitle:
                                        _getLanguageName(locale.languageCode, l10n),
                                    onTap: () =>
                                        _showLanguageDialog(context, ref, l10n),
                                    isDark: isDark,
                                  ),
                                  Divider(
                                      height: 1,
                                      indent: 56,
                                      endIndent: 16,
                                      color:
                                          isDark ? Colors.grey[800] : Colors.grey[200]),
                                  _settingsTile(
                                    context,
                                    icon: Icons.palette_outlined,
                                    title: l10n.theme,
                                    subtitle: _getThemeModeName(themeMode, l10n),
                                    onTap: () => _showThemeDialog(context, ref, l10n),
                                    isDark: isDark,
                                  ),
                                  Divider(
                                      height: 1,
                                      indent: 56,
                                      endIndent: 16,
                                      color:
                                          isDark ? Colors.grey[800] : Colors.grey[200]),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 4),
                                    leading: Icon(Icons.notifications_outlined,
                                        color: Theme.of(context).colorScheme.primary),
                                    title: Text(l10n.notifications),
                                    trailing: Switch(
                                      value: notificationsEnabled,
                                      onChanged: (value) {
                                        ref
                                            .read(notificationsEnabledProvider.notifier)
                                            .setEnabled(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Help & Support Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              _linkTile(context, Icons.help_outline, l10n.helpSupport,
                                  isDark),
                              Divider(
                                  height: 1,
                                  indent: 56,
                                  endIndent: 16,
                                  color: isDark ? Colors.grey[800] : Colors.grey[200]),
                              _linkTile(context, Icons.description_outlined,
                                  l10n.termsConditions, isDark),
                              Divider(
                                  height: 1,
                                  indent: 56,
                                  endIndent: 16,
                                  color: isDark ? Colors.grey[800] : Colors.grey[200]),
                              _linkTile(context, Icons.privacy_tip_outlined,
                                  l10n.privacyPolicy, isDark),
                              Divider(
                                  height: 1,
                                  indent: 56,
                                  endIndent: 16,
                                  color: isDark ? Colors.grey[800] : Colors.grey[200]),
                              _linkTile(
                                  context, Icons.info_outline, l10n.aboutUs, isDark),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(context, ref, l10n),
                            icon: const Icon(Icons.logout, size: 20),
                            label: Text(l10n.logout),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.colorError,
                              side: const BorderSide(color: AppColors.colorError),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        '${l10n.version} 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _profileListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.colorMain, size: 22),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.colorMain, size: 22),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
        ),
      ),
      trailing: Icon(Icons.chevron_right,
          color: isDark ? Colors.grey[500] : Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _linkTile(
      BuildContext context, IconData icon, String title, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.colorMain, size: 22),
      title: Text(title),
      trailing: Icon(Icons.chevron_right,
          color: isDark ? Colors.grey[500] : Colors.grey[400]),
      onTap: () {},
    );
  }

  Widget _ownerMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.english;
      case 'ru':
        return l10n.russian;
      case 'kk':
        return l10n.kazakh;
      default:
        return languageCode;
    }
  }

  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      default:
        return l10n.systemDefault;
    }
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.russian),
              value: 'ru',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.kazakh),
              value: 'kk',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final currentThemeMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightMode),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkMode),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemDefault),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              // Ensure any user-specific cached state is cleared instantly.
              ref.invalidate(savedCardsProvider);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSubPage extends ConsumerWidget {
  const _FavoritesSubPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(favoritesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myFavorites)),
      body: state.isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 64,
                          color: isDark ? Colors.grey[700] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(l10n.noFavorites,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: VenueCard(
                      venue: state.items[i],
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => VenueDetailPage(
                                  venueId: state.items[i].id))),
                    ),
                  ),
                ),
    );
  }
}

class _FacilitiesSubPage extends StatelessWidget {
  const _FacilitiesSubPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myFacilities)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: OwnerMockData.facilities.length,
        itemBuilder: (context, index) {
          final facility = OwnerMockData.facilities[index];
          final statusColor = switch (facility.status) {
            'active' => AppColors.colorSuccess,
            'draft' => AppColors.colorWarning,
            _ => AppColors.colorError,
          };
          final statusText = switch (facility.status) {
            'active' => l10n.statusActive,
            'draft' => l10n.statusDraft,
            _ => l10n.statusSuspended,
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    facility.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        facility.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
