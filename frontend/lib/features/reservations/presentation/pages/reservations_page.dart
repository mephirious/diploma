import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'booking_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../../../../core/widgets/auth_required_screen.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../venues/presentation/providers/venue_provider.dart';
import '../../data/models/booking_model.dart';
import '../providers/reservations_provider.dart';
import '../booking_labels.dart';

class ReservationsPage extends ConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return AuthRequiredScreen(
        title: l10n.reservations,
        description: l10n.reservationsAuthDescription,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: _ReservationsTabLoadSync(
        child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleHeader(title: l10n.reservations),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: TabBar(
                  onTap: (index) {
                    ref.read(selectedReservationTabProvider.notifier).state =
                        index;
                    if (index == 0) {
                      unawaited(ref
                          .read(upcomingBookingsPagedProvider.notifier)
                          .ensureVisible());
                    } else {
                      unawaited(
                        ref.read(pastBookingsPagedProvider.notifier).ensureVisible(),
                      );
                    }
                  },
                  indicator: BoxDecoration(
                    color: AppColors.colorMain,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorMain.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white60 : Colors.grey.shade700,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  tabs: [
                    Tab(text: l10n.upcomingBookings),
                    Tab(text: l10n.pastBookings),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _PaginatedBookingsTabPane(upcoming: true),
                  _PaginatedBookingsTabPane(upcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Loads past/upcoming data when the user switches tabs (tap or swipe).
class _ReservationsTabLoadSync extends ConsumerStatefulWidget {
  final Widget child;

  const _ReservationsTabLoadSync({required this.child});

  @override
  ConsumerState<_ReservationsTabLoadSync> createState() =>
      _ReservationsTabLoadSyncState();
}

class _ReservationsTabLoadSyncState extends ConsumerState<_ReservationsTabLoadSync> {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = DefaultTabController.of(context);
    if (_tabController == next) return;
    _tabController?.removeListener(_onTabChanged);
    _tabController = next;
    _tabController!.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    final c = _tabController;
    if (c == null || c.indexIsChanging) return;
    ref.read(selectedReservationTabProvider.notifier).state = c.index;
    if (c.index == 0) {
      unawaited(
        ref.read(upcomingBookingsPagedProvider.notifier).ensureVisible(),
      );
    } else {
      unawaited(ref.read(pastBookingsPagedProvider.notifier).ensureVisible());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PaginatedBookingsTabPane extends ConsumerStatefulWidget {
  final bool upcoming;

  const _PaginatedBookingsTabPane({required this.upcoming});

  @override
  ConsumerState<_PaginatedBookingsTabPane> createState() =>
      _PaginatedBookingsTabPaneState();
}

class _PaginatedBookingsTabPaneState extends ConsumerState<_PaginatedBookingsTabPane>
    with AutomaticKeepAliveClientMixin {
  static const _prefetchMaxCards = 5;
  static const _prefetchTimeout = Duration(seconds: 6);
  static const _perImageTimeout = Duration(seconds: 3);
  static const _minSkeletonDuration = Duration(milliseconds: 400);

  final ScrollController _scrollController = ScrollController();
  bool _prefetchDoneForBatch = false;
  bool _prefetchRunning = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.upcoming) {
        ref.read(upcomingBookingsPagedProvider.notifier).ensureInitial();
      } else {
        ref.read(pastBookingsPagedProvider.notifier).ensureInitial();
      }
    });
  }

  /// Warms thumbnails for the first screen; timeouts ensure the skeleton never sticks.
  Future<void> _prefetchFirstPageImages(List<BookingModel> bookings) async {
    final ctx = context;
    final batch = bookings.take(_prefetchMaxCards);
    for (final b in batch) {
      if (!mounted) return;
      try {
        String? url;
        final rid = b.resourceId;
        if (rid != null && rid.isNotEmpty) {
          final res = await ref
              .read(resourceByIdProvider(rid).future)
              .timeout(_perImageTimeout);
          url = res?.images.isNotEmpty == true ? res!.images.first : null;
        }
        if (url == null && b.venueId.isNotEmpty) {
          final venue = await ref
              .read(venueByIdProvider(b.venueId).future)
              .timeout(_perImageTimeout);
          url = venue?.images.isNotEmpty == true ? venue!.images.first : null;
        }
        if (url != null && ctx.mounted) {
          await precacheImage(NetworkImage(url), ctx)
              .timeout(_perImageTimeout);
        }
      } catch (_) {
        // Skip failed thumbnails; list still renders with placeholders.
      }
    }
  }

  void _finishPrefetch() {
    if (!mounted) return;
    setState(() {
      _prefetchDoneForBatch = true;
      _prefetchRunning = false;
    });
  }

  void _schedulePrefetch(List<BookingModel> items) {
    if (_prefetchRunning || _prefetchDoneForBatch || items.isEmpty) return;
    _prefetchRunning = true;
    final started = DateTime.now();

    Future<void>(() async {
      try {
        await _prefetchFirstPageImages(items)
            .timeout(_prefetchTimeout, onTimeout: () {});
      } catch (_) {}
      final elapsed = DateTime.now().difference(started);
      final remaining = _minSkeletonDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
    }).whenComplete(_finishPrefetch);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 280) return;
    if (widget.upcoming) {
      ref.read(upcomingBookingsPagedProvider.notifier).loadMore();
    } else {
      ref.read(pastBookingsPagedProvider.notifier).loadMore();
    }
  }

  PaginatedBookingsState _state(WidgetRef r) => widget.upcoming
      ? r.watch(upcomingBookingsPagedProvider)
      : r.watch(pastBookingsPagedProvider);

  Future<void> _retry() async {
    if (widget.upcoming) {
      await ref.read(upcomingBookingsPagedProvider.notifier).reset();
    } else {
      await ref.read(pastBookingsPagedProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = _state(ref);

    ref.listen<PaginatedBookingsState>(
      widget.upcoming
          ? upcomingBookingsPagedProvider
          : pastBookingsPagedProvider,
      (prev, next) {
        if (next.loadingInitial) {
          setState(() {
            _prefetchDoneForBatch = false;
            _prefetchRunning = false;
          });
        } else if (next.items.isNotEmpty &&
            !_prefetchDoneForBatch &&
            !_prefetchRunning) {
          _schedulePrefetch(next.items);
        }
      },
    );

    if (state.items.isNotEmpty &&
        !_prefetchDoneForBatch &&
        !_prefetchRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _schedulePrefetch(state.items);
      });
    }

    if (state.loadingInitial && state.items.isEmpty) {
      return _ThreeBookingCardSkeletons(
        key: const ValueKey('bookings_skeleton_initial'),
        isDark: isDark,
      );
    }

    if (state.error != null &&
        state.error!.isNotEmpty &&
        state.items.isEmpty) {
      final errRaw = state.error!;
      final errText = errRaw == 'not_logged_in'
          ? l10n.notLoggedInError
          : errRaw;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _retry,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty && !state.loadingInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noBookings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.startBooking,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final showThumbnailSkeleton =
        state.items.isNotEmpty && !_prefetchDoneForBatch;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: showThumbnailSkeleton
          ? _ThreeBookingCardSkeletons(
              key: ValueKey(
                'bookings_skeleton_${widget.upcoming ? 'up' : 'past'}',
              ),
              isDark: isDark,
            )
          : RefreshIndicator(
              key: ValueKey(
                'bookings_list_${widget.upcoming ? 'up' : 'past'}',
              ),
              onRefresh: _retry,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final booking = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BookingBriefCard(
                      booking: booking,
                      isDark: isDark,
                      l10n: l10n,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              BookingDetailPage(bookingId: booking.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// Same footprint as [_BookingBriefCard] — three grey shimmer rows.
class _ThreeBookingCardSkeletons extends StatelessWidget {
  final bool isDark;

  const _ThreeBookingCardSkeletons({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: border),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 108,
                child: Row(
                  children: [
                    ShimmerBox(
                      width: 100,
                      height: 108,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(19),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(
                              height: 16,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 8),
                            ShimmerBox(
                              height: 12,
                              width: 140,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 6),
                            ShimmerBox(
                              height: 12,
                              width: 180,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const Spacer(),
                            ShimmerBox(
                              height: 14,
                              width: 90,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BookingBriefCard extends ConsumerWidget {
  final BookingModel booking;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _BookingBriefCard({
    required this.booking,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rid = booking.resourceId ?? '';
    final resourceAsync = ref.watch(resourceByIdProvider(rid));
    final venueAsync = ref.watch(venueByIdProvider(booking.venueId));
    final resource = resourceAsync.valueOrNull;
    final title = resource?.displayName ??
        venueAsync.valueOrNull?.name ??
        l10n.venueIdFallback(booking.venueId);
    String? imageUrl;
    if (resource?.images.isNotEmpty == true) {
      imageUrl = resource!.images.first;
    } else if (venueAsync.valueOrNull?.images.isNotEmpty == true) {
      imageUrl = venueAsync.valueOrNull!.images.first;
    }

    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Material(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(19),
              ),
              child: SizedBox(
                width: 100,
                height: 108,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _thumbPlaceholder(),
                      )
                    : _thumbPlaceholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusDot(
                          status: booking.status,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.startAtForDisplay != null
                          ? DateFormat('EEE, MMM d')
                              .format(booking.startAtForDisplay!)
                          : '—',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${booking.startTimeStr} – ${booking.endTimeStr}'
                      '${booking.timezone != null ? ' · ${booking.timezone}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${booking.priceTotalInt} ₸',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.colorMain,
                          ),
                        ),
                        if (booking.paymentStatus != null &&
                            booking.paymentStatus!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.colorMain.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              localizedPaymentStatus(
                                l10n,
                                booking.paymentStatus!,
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbPlaceholder() {
    return ColoredBox(
      color: isDark ? const Color(0xFF21262D) : const Color(0xFFE8ECF0),
      child: Icon(Icons.sports_soccer_rounded,
          color: AppColors.colorMain.withValues(alpha: 0.45), size: 36),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  final bool isDark;
  final AppLocalizations l10n;

  const _StatusDot({
    required this.status,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final c = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: isDark ? 0.28 : 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        localizedBookingStatus(l10n, status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: c,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s.toLowerCase()) {
      case 'created':
      case 'pending':
      case 'hold':
        return AppColors.colorWarning;
      case 'confirmed':
        return AppColors.colorSuccess;
      case 'completed':
        return AppColors.colorInfo;
      case 'cancelled':
        return AppColors.colorError;
      default:
        return AppColors.colorMain;
    }
  }
}
