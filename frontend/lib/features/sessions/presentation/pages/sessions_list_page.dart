import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sports/sport_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reservations/presentation/booking_labels.dart';
import '../../../venues/data/models/venue_model.dart';
import '../../../venues/presentation/pages/booking_page.dart';
import '../../data/models/session_model_simple.dart';
import '../providers/sessions_provider.dart';
import '../session_price_text.dart';
import '../widgets/session_card.dart';
import '../widgets/session_venue_info_block.dart';

class SessionsPage extends ConsumerStatefulWidget {
  const SessionsPage({super.key});

  @override
  ConsumerState<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends ConsumerState<SessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(sessionsListProvider.notifier).ensureLoaded());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listState = ref.watch(sessionsListProvider);
    final selectedSport = ref.watch(selectedSportFilterProvider);
    final selectedTime = ref.watch(selectedTimeFilterProvider);
    final sessions = listState.items;

    ref.listen<String>(selectedSportFilterProvider, (_, __) {
      unawaited(ref.read(sessionsListProvider.notifier).refresh());
    });
    ref.listen<String>(selectedTimeFilterProvider, (prev, next) {
      if (next != 'date') {
        unawaited(ref.read(sessionsListProvider.notifier).refresh());
      }
    });
    ref.listen<DateTime?>(selectedSessionDateProvider, (_, date) {
      if (date != null && ref.read(selectedTimeFilterProvider) == 'date') {
        unawaited(ref.read(sessionsListProvider.notifier).refresh());
      }
    });
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        unawaited(ref.read(sessionsListProvider.notifier).refresh());
      }
    });

    final locale = Localizations.localeOf(context).toString();
    final sortedSports = sortedSportCategories(l10n, locale);
    final sportCategories = [
      {'key': 'all', 'label': l10n.allCategories, 'icon': Icons.apps},
      ...sortedSports.map(
        (c) => {'key': c.key, 'label': c.label, 'icon': c.icon},
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(sessionsListProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: PageTitleHeader(title: l10n.sessions),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimeFilterChip(
                          label: l10n.now,
                          icon: Icons.circle,
                          iconSize: 8,
                          isSelected: selectedTime == 'now',
                          isLive: true,
                          onTap: () => ref
                              .read(selectedTimeFilterProvider.notifier)
                              .state = 'now',
                        ),
                        const SizedBox(width: 8),
                        _TimeFilterChip(
                          label: l10n.today,
                          icon: Icons.today,
                          isSelected: selectedTime == 'today',
                          onTap: () => ref
                              .read(selectedTimeFilterProvider.notifier)
                              .state = 'today',
                        ),
                        const SizedBox(width: 8),
                        _TimeFilterChip(
                          label: l10n.pickDate,
                          icon: Icons.calendar_month,
                          isSelected: selectedTime == 'date',
                          onTap: () => _pickSessionDate(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    scrollDirection: Axis.horizontal,
                    itemCount: sportCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = sportCategories[index];
                      final key = cat['key'] as String;
                      final isSelected = selectedSport == key;

                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          cat['icon'] as IconData,
                          size: 16,
                          color:
                              isSelected ? Colors.white : AppColors.colorMain,
                        ),
                        label: Text(cat['label'] as String),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey[800]),
                        ),
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey[100],
                        selectedColor: AppColors.colorMain,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onSelected: (_) {
                          ref.read(selectedSportFilterProvider.notifier).state =
                              key;
                        },
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (listState.loading && listState.items.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (listState.error != null && listState.items.isEmpty)
                SliverFillRemaining(
                  child: _SessionsErrorView(
                    message: listState.error!,
                    onRetry: () =>
                        ref.read(sessionsListProvider.notifier).refresh(),
                  ),
                )
              else if (sessions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_outlined,
                          size: 64,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noSessions,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.findSessions,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = sessions[index];
                        final inProgress =
                            listState.actionInProgress.contains(session.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SessionCard(
                            session: session,
                            actionLoading: inProgress,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SessionDetailPage(
                                    sessionId: session.id,
                                  ),
                                ),
                              );
                            },
                            onJoin: () => _handleJoin(context, session.id),
                          ),
                        );
                      },
                      childCount: sessions.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSessionDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = ref.read(selectedSessionDateProvider) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    ref.read(selectedSessionDateProvider.notifier).state = picked;
    ref.read(selectedTimeFilterProvider.notifier).state = 'date';
  }

  Future<void> _handleJoin(BuildContext context, String sessionId) async {
    SessionModelSimple? session;
    for (final item in ref.read(sessionsListProvider).items) {
      if (item.id == sessionId) {
        session = item;
        break;
      }
    }
    if (session == null) return;
    final paySession = session;

    if (!ref.read(isLoggedInProvider)) {
      final result = 'login_required';
      if (result == 'login_required') {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        if (!context.mounted) return;
        if (ref.read(isLoggedInProvider)) {
          await _handleJoin(context, sessionId);
        }
      }
      return;
    }

    final venue = VenueModel(
      id: paySession.venueId,
      name: paySession.venueName,
      description: paySession.description,
      category: paySession.sportType,
      address: paySession.venueAddress,
      latitude: 0,
      longitude: 0,
      pricePerHour: paySession.pricePerPlayer,
      rating: 0,
      reviewCount: 0,
      images: paySession.venueImage.isNotEmpty
          ? [paySession.venueImage]
          : (paySession.coverImage.isNotEmpty
              ? [paySession.coverImage]
              : const []),
      amenities: const [],
      openingHours: '',
      isOpen: true,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentPage.forSession(session: paySession, venue: venue),
      ),
    );
    if (!context.mounted) return;
    ref.invalidate(sessionDetailProvider(sessionId));
    unawaited(ref.read(sessionsListProvider.notifier).ensureLoaded());
  }
}

class _SessionsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SessionsErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _TimeFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final bool isSelected;
  final bool isLive;
  final VoidCallback onTap;

  const _TimeFilterChip({
    required this.label,
    required this.icon,
    this.iconSize = 16,
    required this.isSelected,
    this.isLive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.colorMain
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.grey[300]!,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive && isSelected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(
                icon,
                size: iconSize,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            if (iconSize >= 16) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionDetailPage extends ConsumerWidget {
  final String sessionId;

  const SessionDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(sessionDetailProvider(sessionId));
    final listState = ref.watch(sessionsListProvider);
    final inProgress = listState.actionInProgress.contains(sessionId);

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: _SessionsErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
        ),
      ),
      data: (session) => _SessionDetailBody(
        session: session,
        actionLoading: inProgress,
        onJoin: () => _handleJoin(context, ref, session),
        onLeave: () => _handleLeave(context, ref, session.id),
      ),
    );
  }

  Future<void> _handleJoin(
    BuildContext context,
    WidgetRef ref,
    SessionModelSimple session,
  ) async {
    if (!ref.read(isLoggedInProvider)) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      if (context.mounted) {
        await _handleJoin(context, ref, session);
      }
      return;
    }

    final venue = VenueModel(
      id: session.venueId,
      name: session.venueName,
      description: session.description,
      category: session.sportType,
      address: session.venueAddress,
      latitude: 0,
      longitude: 0,
      pricePerHour: session.pricePerPlayer,
      rating: 0,
      reviewCount: 0,
      images: session.venueImage.isNotEmpty
          ? [session.venueImage]
          : (session.coverImage.isNotEmpty
              ? [session.coverImage]
              : const []),
      amenities: const [],
      openingHours: '',
      isOpen: true,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage.forSession(session: session, venue: venue),
      ),
    );
    ref.invalidate(sessionDetailProvider(session.id));
  }

  Future<void> _handleLeave(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveSession),
        content: Text(l10n.leaveSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.leaveSession),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result =
        await ref.read(sessionsListProvider.notifier).leaveSession(sessionId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == null ? l10n.leftSessionSuccessfully : result,
        ),
        backgroundColor:
            result == null ? AppColors.colorSuccess : AppColors.colorError,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.invalidate(sessionDetailProvider(sessionId));
  }
}

class _SessionDetailBody extends StatelessWidget {
  final SessionModelSimple session;
  final bool actionLoading;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _SessionDetailBody({
    required this.session,
    required this.actionLoading,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryAction = session.isJoined && session.canLeave
        ? _DetailAction.leave
        : session.canJoin
            ? _DetailAction.join
            : _DetailAction.disabled;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  session.coverImage.isNotEmpty
                      ? Image.network(
                          session.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.colorMain.withOpacity(0.3),
                            child: const Icon(
                              Icons.sports,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.colorMain.withOpacity(0.3),
                          child: const Icon(
                            Icons.sports,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (session.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.live,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          session.displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (session.resourceName.trim().isNotEmpty &&
                            session.resourceName.trim() !=
                                session.displayTitle) ...[
                          const SizedBox(height: 6),
                          Text(
                            session.resourceName.trim(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.colorMain.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          sportLabel(l10n, session.sportType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.colorMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (session.hasVenueInfo) ...[
                    const SizedBox(height: 20),
                    SessionVenueInfoBlock(
                      venueName: session.venueName,
                      venueAddress: session.venueAddress,
                      distance: session.distance,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                  if (session.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      session.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: l10n.host,
                          value: session.hostName,
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.group_outlined,
                          label: l10n.participants,
                          value: l10n.playersCount(
                            session.currentPlayers,
                            session.maxPlayers,
                          ),
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.attach_money,
                          label: l10n.pricePerPerson,
                          value: sessionPriceLabel(l10n, session),
                        ),
                        if (session.pricingModel == 'fixed_split') ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.fixedSplitPriceDisclosure,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                            ),
                          ),
                        ],
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: l10n.time,
                          value: session.timeSlots.join(' – '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: session.isCancelled
                          ? AppColors.colorError.withOpacity(0.1)
                          : !session.slotAvailable
                              ? Colors.orange.withOpacity(0.12)
                              : session.isFull
                                  ? Colors.red.withOpacity(0.1)
                                  : AppColors.colorSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          session.isCancelled
                              ? Icons.cancel_outlined
                              : !session.slotAvailable
                                  ? Icons.event_busy_outlined
                                  : session.isJoined
                                      ? Icons.check_circle
                                      : session.isFull
                                          ? Icons.block
                                          : Icons.check_circle_outline,
                          color: session.isCancelled
                              ? AppColors.colorError
                              : !session.slotAvailable
                                  ? Colors.orange
                                  : session.isJoined
                                      ? AppColors.colorSuccess
                                      : session.isFull
                                          ? Colors.red
                                          : AppColors.colorSuccess,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.isCancelled
                                    ? l10n.cancelled
                                    : !session.slotAvailable
                                        ? l10n.unavailable
                                        : session.isJoined
                                            ? l10n.joinedLabel
                                            : l10n.spotsAvailable,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: session.isCancelled
                                      ? AppColors.colorError
                                      : null,
                                ),
                              ),
                              if (session.isCancelled &&
                                  session.cancelReason != null &&
                                  session.cancelReason!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    localizedCancellationReason(
                                      l10n,
                                      session.cancelReason!,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                )
                              else if (!session.isCancelled &&
                                  !session.slotAvailable)
                                Text(
                                  l10n.facilityUnavailableHint,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                )
                              else if (!session.isCancelled && !session.isJoined)
                                Text(
                                  l10n.spotsLeft(session.spotsLeft),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: primaryAction == _DetailAction.leave
              ? OutlinedButton(
                  onPressed: actionLoading ? null : onLeave,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _ActionLabel(
                    loading: actionLoading,
                    label: l10n.leaveSession,
                  ),
                )
              : ElevatedButton(
                  onPressed:
                      primaryAction == _DetailAction.join && !actionLoading
                          ? onJoin
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: session.isCancelled
                        ? Colors.grey
                        : session.isJoined
                            ? AppColors.colorSuccess
                            : AppColors.colorMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _ActionLabel(
                    loading: actionLoading,
                    label: session.isCancelled
                        ? l10n.cancelled
                        : session.isJoined
                            ? l10n.joinedLabel
                            : session.isFull
                                ? l10n.sessionFull
                                : !session.slotAvailable
                                    ? l10n.unavailable
                                    : !session.canJoin && !session.isJoined
                                        ? l10n.sessionLocked
                                        : l10n.joinSession,
                  ),
                ),
        ),
      ),
    );
  }
}

enum _DetailAction { join, leave, disabled }

class _ActionLabel extends StatelessWidget {
  final bool loading;
  final String label;

  const _ActionLabel({required this.loading, required this.label});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.colorMain),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
