import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/booking_model.dart';
import '../providers/reservations_provider.dart';
import '../booking_labels.dart';
import '../../../venues/data/models/venue_model.dart';
import '../../../venues/presentation/pages/booking_page.dart';
import '../../../venues/presentation/providers/venue_provider.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  bool _contentReady = false;
  String? _lastPreparedBookingId;

  Future<void> _prepareContent(BookingModel booking) async {
    try {
      String? url;
      final rid = booking.resourceId;
      if (rid != null && rid.isNotEmpty) {
        final res = await ref.read(resourceByIdProvider(rid).future);
        url = res?.images.isNotEmpty == true ? res!.images.first : null;
      }
      if (url == null) {
        final venue = await ref.read(venueByIdProvider(booking.venueId).future);
        url = venue?.images.isNotEmpty == true ? venue!.images.first : null;
      }
      if (url != null && mounted) {
        await precacheImage(NetworkImage(url), context);
      }
      await ref.read(venueByIdProvider(booking.venueId).future);
    } catch (_) {}
    if (mounted) setState(() => _contentReady = true);
  }

  Future<void> _openPayment(
    BuildContext context,
    BookingModel booking,
    VenueModel venue,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage.forExistingBooking(
          booking: booking,
          venue: venue,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _contentReady = false;
      _lastPreparedBookingId = null;
    });
    ref.invalidate(bookingByIdProvider(widget.bookingId));
    final updated =
        await ref.read(bookingByIdProvider(widget.bookingId).future);
    if (updated != null && mounted) {
      ref.invalidate(venueByIdProvider(updated.venueId));
      final rid = updated.resourceId;
      if (rid != null && rid.isNotEmpty) {
        ref.invalidate(resourceByIdProvider(rid));
      }
      await _prepareContent(updated);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _contentReady = false;
      _lastPreparedBookingId = null;
    });
    ref.invalidate(bookingByIdProvider(widget.bookingId));
    final booking =
        await ref.read(bookingByIdProvider(widget.bookingId).future);
    if (booking != null && mounted) {
      ref.invalidate(venueByIdProvider(booking.venueId));
      final rid = booking.resourceId;
      if (rid != null && rid.isNotEmpty) {
        ref.invalidate(resourceByIdProvider(rid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingAsync = ref.watch(bookingByIdProvider(widget.bookingId));
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: bookingAsync.when(
        loading: () => _BookingDetailSkeletonFull(isDark: isDark),
        error: (e, _) => _ErrorBody(
          message: '$e',
          onRetry: () => ref.invalidate(bookingByIdProvider(widget.bookingId)),
          retryLabel: l10n.retry,
        ),
        data: (booking) {
          if (booking == null) {
            return _ErrorBody(
              message: l10n.bookingNotFound,
              onRetry: () =>
                  ref.invalidate(bookingByIdProvider(widget.bookingId)),
              retryLabel: l10n.retry,
            );
          }
          if (!_contentReady) {
            if (_lastPreparedBookingId != booking.id) {
              _lastPreparedBookingId = booking.id;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _prepareContent(booking);
              });
            }
            return _BookingDetailSkeletonFull(isDark: isDark);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: _BookingDetailScrollView(
              booking: booking,
              isDark: isDark,
              l10n: l10n,
              onCancel: () =>
                  _showCancelDialog(context, ref, booking.id, l10n),
              onPay: (b, v) => _openPayment(context, b, v),
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.colorError.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.cancel_outlined,
                  color: AppColors.colorError, size: 20),
            ),
            const SizedBox(width: 12),
            Text(l10n.cancelBooking),
          ],
        ),
        content: Text(l10n.confirmCancel),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(cancelBookingProvider(id).future);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.bookingCancelled),
                    backgroundColor: AppColors.colorSuccess,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
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

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------
class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-screen skeleton (same layout as loaded detail)
// ---------------------------------------------------------------------------
class _BookingDetailSkeletonFull extends StatelessWidget {
  final bool isDark;

  const _BookingDetailSkeletonFull({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          stretch: false,
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          leading: const _CircleBackButton(),
          flexibleSpace: FlexibleSpaceBar(
            background: SizedBox(
              width: double.infinity,
              height: 260,
              child: ShimmerBox(
                height: 260,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          height: 44,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ShimmerBox(
                          height: 44,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ShimmerBox(
                          height: 44,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ShimmerBox(
                    height: 12,
                    width: 140,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  ShimmerBox(
                    height: 140,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  const SizedBox(height: 20),
                  ShimmerBox(
                    height: 12,
                    width: 110,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  ShimmerBox(
                    height: 88,
                    borderRadius: BorderRadius.circular(18),
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

// ---------------------------------------------------------------------------
// Main scroll view
// ---------------------------------------------------------------------------
class _BookingDetailScrollView extends ConsumerWidget {
  final BookingModel booking;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final void Function(BookingModel booking, VenueModel venue) onPay;

  const _BookingDetailScrollView({
    required this.booking,
    required this.isDark,
    required this.l10n,
    required this.onCancel,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rid = booking.resourceId ?? '';
    final resourceAsync = ref.watch(resourceByIdProvider(rid));
    final venueAsync = ref.watch(venueByIdProvider(booking.venueId));
    final resource = resourceAsync.valueOrNull;
    final venue = venueAsync.valueOrNull;

    final heroName = resource?.displayName ??
        venue?.name ??
        l10n.bookingFallbackTitle;
    final imageUrl = resource?.images.isNotEmpty == true
        ? resource!.images.first
        : (venue?.images.isNotEmpty == true ? venue!.images.first : null);

    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final isCancellable = booking.status != 'cancelled' &&
        booking.status != 'completed' &&
        (booking.startAt?.isAfter(DateTime.now()) ?? false);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      slivers: [
        // ── Hero image ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          stretch: false,
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: const _CircleBackButton(),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _HeroFallback(isDark: isDark, name: heroName),
                  )
                else
                  _HeroFallback(isDark: isDark, name: heroName),

                // gradient scrim
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.30),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),

                // venue name + status chip
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heroName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(blurRadius: 16, color: Colors.black54),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusChip(status: booking.status, l10n: l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Quick summary row ────────────────────────────
                    _QuickSummaryRow(booking: booking, l10n: l10n, sub: sub),

                    if (venue != null &&
                        (venue.address.trim().isNotEmpty ||
                            _venueHasAnyContact(venue))) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.location, sub: sub),
                      const SizedBox(height: 12),
                      _LocationContactsCard(
                        venue: venue,
                        isDark: isDark,
                        cardBg: cardBg,
                        primary: primary,
                        sub: sub,
                        l10n: l10n,
                        onOpenContacts: _venueHasAnyContact(venue)
                            ? () => _showVenueContactsSidePanel(
                                  context,
                                  venue,
                                  isDark,
                                  l10n,
                                )
                            : null,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Section: Date & time ────────────────────────
                    _SectionHeader(title: l10n.bookingDetails, sub: sub),
                    const SizedBox(height: 12),

                    _InfoCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_month_rounded,
                            label: l10n.date,
                            value: booking.startAtForDisplay != null
                                ? DateFormat('EEE, MMM d, yyyy')
                                    .format(booking.startAtForDisplay!)
                                : '—',
                            primary: primary,
                            sub: sub,
                          ),
                          _ThinDivider(isDark: isDark),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: l10n.time,
                            value:
                                '${booking.startTimeStr} – ${booking.endTimeStr}',
                            primary: primary,
                            sub: sub,
                          ),
                          _ThinDivider(isDark: isDark),
                          _DetailRow(
                            icon: Icons.timelapse_rounded,
                            label: l10n.duration,
                            value:
                                '${booking.durationHours} ${booking.durationHours == 1 ? l10n.hour : l10n.hours}',
                            primary: primary,
                            sub: sub,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Section: Payment ─────────────────────────────
                    _SectionHeader(title: l10n.totalPrice, sub: sub),
                    const SizedBox(height: 12),

                    _InfoCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.payments_rounded,
                            label: l10n.totalPrice,
                            value:
                                '${booking.priceTotalInt} ${_currencySuffix(booking)}',
                            primary: primary,
                            sub: sub,
                            valueBold: true,
                          ),
                          if (booking.paymentStatus != null &&
                              booking.paymentStatus!.isNotEmpty) ...[
                            _ThinDivider(isDark: isDark),
                            _DetailRow(
                              icon: Icons.receipt_long_rounded,
                              label: l10n.paymentRowLabel,
                              value: localizedPaymentStatus(
                                  l10n, booking.paymentStatus!),
                              primary: primary,
                              sub: sub,
                              trailing: _PaymentDot(
                                  status: booking.paymentStatus!),
                            ),
                          ],
                          if (booking.holdExpiresAt != null) ...[
                            _ThinDivider(isDark: isDark),
                            _DetailRow(
                              icon: Icons.timer_outlined,
                              label: l10n.holdExpiresLabel,
                              value: DateFormat('MMM d, HH:mm')
                                  .format(booking.holdExpiresAt!.toLocal()),
                              primary: primary,
                              sub: sub,
                            ),
                          ],
                          if (booking.needsPaymentCompletion) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: venue != null
                                    ? () => onPay(booking, venue!)
                                    : null,
                                icon: const Icon(Icons.payment_rounded, size: 20),
                                label: Text(l10n.payNowLabel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.colorMain,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.colorMain.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Section: Session / extra info ────────────────
                    if (booking.sessionId != null &&
                        booking.sessionId!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: l10n.sessionSectionTitle, sub: sub),
                      const SizedBox(height: 12),
                      _InfoCard(
                        isDark: isDark,
                        cardBg: cardBg,
                        child: _DetailRow(
                          icon: Icons.groups_rounded,
                          label: l10n.sessionIdLabel,
                          value: booking.sessionId!,
                          primary: primary,
                          sub: sub,
                          mono: true,
                        ),
                      ),
                    ],

                    // ── Cancel reason ────────────────────────────────
                    if (booking.cancelReason != null &&
                        booking.cancelReason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InfoCard(
                        isDark: isDark,
                        cardBg: cardBg,
                        accent: AppColors.colorError,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 20, color: AppColors.colorError),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.cancellationReasonLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.colorError,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizedCancellationReason(
                                        l10n,
                                        booking.cancelReason!,
                                      ),
                                      style: TextStyle(
                                          fontSize: 14, color: primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ── Booking ID ───────────────────────────────────
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        l10n.bookingIdLine(booking.id),
                        style: TextStyle(
                          fontSize: 11,
                          color: sub.withValues(alpha: 0.6),
                          fontFamily: 'monospace',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    // ── Cancel button ────────────────────────────────
                    if (isCancellable) ...[
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: Text(l10n.cancelBooking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.colorError,
                            side: const BorderSide(
                              color: AppColors.colorError,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _currencySuffix(BookingModel b) {
    final c = b.currency?.toUpperCase();
    if (c == 'KZT') return '₸';
    if (c != null && c.isNotEmpty) return c;
    return '₸';
  }

}

// ---------------------------------------------------------------------------
// Quick summary – the "at-a-glance" strip right below the hero
// ---------------------------------------------------------------------------
class _QuickSummaryRow extends StatelessWidget {
  final BookingModel booking;
  final AppLocalizations l10n;
  final Color sub;

  const _QuickSummaryRow({
    required this.booking,
    required this.l10n,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final dateStr = booking.startAtForDisplay != null
        ? DateFormat('MMM d').format(booking.startAtForDisplay!)
        : '—';
    final timeStr = booking.startTimeStr;
    final priceStr =
        '${booking.priceTotalInt} ${_BookingDetailScrollView._currencySuffix(booking)}';

    return Row(
      children: [
        _SummaryPill(
            icon: Icons.calendar_today_rounded,
            text: dateStr,
            primary: primary,
            sub: sub,
            isDark: isDark),
        const SizedBox(width: 8),
        _SummaryPill(
            icon: Icons.schedule_rounded,
            text: timeStr,
            primary: primary,
            sub: sub,
            isDark: isDark),
        const SizedBox(width: 8),
        _SummaryPill(
            icon: Icons.payments_rounded,
            text: priceStr,
            primary: primary,
            sub: sub,
            isDark: isDark),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primary;
  final Color sub;
  final bool isDark;

  const _SummaryPill({
    required this.icon,
    required this.text,
    required this.primary,
    required this.sub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.colorMain.withValues(alpha: isDark ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.colorMain),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.38),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _StatusChip({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status.toLowerCase()) {
      'confirmed' || 'active' => (
        const Color(0xFF16A34A),
        Colors.white,
      ),
      'created' || 'pending' || 'hold' => (
        const Color(0xFFF59E0B),
        const Color(0xFF1C1917),
      ),
      'cancelled' => (
        AppColors.colorError,
        Colors.white,
      ),
      'completed' => (
        const Color(0xFF6366F1),
        Colors.white,
      ),
      _ => (
        Colors.white.withValues(alpha: 0.25),
        Colors.white,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        localizedBookingStatus(l10n, status).toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color sub;

  const _SectionHeader({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: sub,
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  final bool isDark;
  final String name;

  const _HeroFallback({required this.isDark, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1C2128) : const Color(0xFF2D6A5E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer_rounded,
                size: 64, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info card container
// ---------------------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Widget child;
  final Color? accent;

  const _InfoCard({
    required this.isDark,
    required this.cardBg,
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent?.withValues(alpha: 0.3) ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row (replaces the old _Tile)
// ---------------------------------------------------------------------------
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final Color sub;
  final bool mono;
  final bool valueBold;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
    required this.sub,
    this.mono = false,
    this.valueBold = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.colorMain.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.colorMain),
          ),
          const SizedBox(width: 14),

          // label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: sub,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: mono ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mono ? 12 : (valueBold ? 18 : 15),
                    fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                    color: primary,
                    fontFamily: mono ? 'monospace' : null,
                    letterSpacing: valueBold ? -0.3 : 0,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thin divider
// ---------------------------------------------------------------------------
class _ThinDivider extends StatelessWidget {
  final bool isDark;

  const _ThinDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment status dot
// ---------------------------------------------------------------------------
class _PaymentDot extends StatelessWidget {
  final String status;

  const _PaymentDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'paid' || 'completed' || 'succeeded' => const Color(0xFF16A34A),
      'pending' || 'hold' => const Color(0xFFF59E0B),
      'failed' || 'refunded' => AppColors.colorError,
      _ => Colors.grey,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location & contacts (venue address + resource is hero)
// ---------------------------------------------------------------------------

bool _venueHasAnyContact(VenueModel v) =>
    v.contacts.any((c) => c.hasPhone || c.hasEmail || c.hasLink);

void _showVenueContactsSidePanel(
  BuildContext context,
  VenueModel venue,
  bool isDark,
  AppLocalizations l10n,
) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      final w = MediaQuery.of(ctx).size.width;
      final h = MediaQuery.of(ctx).size.height;
      return Align(
        alignment: Alignment.centerRight,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: Material(
            elevation: 24,
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
            child: SizedBox(
              width: min(w * 0.92, 420),
              height: h,
              child: _VenueContactsSlideBody(
                venue: venue,
                isDark: isDark,
                l10n: l10n,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _LocationContactsCard extends StatelessWidget {
  final VenueModel venue;
  final bool isDark;
  final Color cardBg;
  final Color primary;
  final Color sub;
  final AppLocalizations l10n;
  final VoidCallback? onOpenContacts;

  const _LocationContactsCard({
    required this.venue,
    required this.isDark,
    required this.cardBg,
    required this.primary,
    required this.sub,
    required this.l10n,
    this.onOpenContacts,
  });

  @override
  Widget build(BuildContext context) {
    final addr = venue.address.trim();
    final hasAddr = addr.isNotEmpty;
    final hasContacts = _venueHasAnyContact(venue);

    return _InfoCard(
      isDark: isDark,
      cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasAddr)
            _DetailRow(
              icon: Icons.location_on_rounded,
              label: l10n.addressLabel,
              value: addr,
              primary: primary,
              sub: sub,
            ),
          if (hasAddr && hasContacts && onOpenContacts != null)
            _ThinDivider(isDark: isDark),
          if (hasContacts && onOpenContacts != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenContacts,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.colorMain.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.contact_mail_rounded,
                          size: 20,
                          color: AppColors.colorMain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.bookingContactInfoTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: sub,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.bookingContactInfoSubtitle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub, size: 26),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VenueContactsSlideBody extends StatelessWidget {
  final VenueModel venue;
  final bool isDark;
  final AppLocalizations l10n;

  const _VenueContactsSlideBody({
    required this.venue,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final items = venue.contacts
        .where((c) => c.hasPhone || c.hasEmail || c.hasLink)
        .toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    venue.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: sub,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.contactsSectionTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: sub,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = items[i];
                return _VenueContactTile(
                  contact: c,
                  primary: primary,
                  sub: sub,
                  l10n: l10n,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueContactTile extends StatelessWidget {
  final VenueContact contact;
  final Color primary;
  final Color sub;
  final AppLocalizations l10n;

  const _VenueContactTile({
    required this.contact,
    required this.primary,
    required this.sub,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (contact.hasPhone) {
      return _ContactCard(
        icon: Icons.phone_in_talk_rounded,
        iconBg: const Color(0xFF0D9488),
        title: contact.label.isNotEmpty ? contact.label : l10n.contactTypePhoneDefault,
        subtitle: contact.phone!,
        primary: primary,
        sub: sub,
        onTap: () async {
          final uri = Uri.parse('tel:${_normalizePhoneForDial(contact.phone!)}');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      );
    }
    if (contact.hasEmail) {
      return _ContactCard(
        icon: Icons.email_rounded,
        iconBg: const Color(0xFF2563EB),
        title: contact.label.isNotEmpty ? contact.label : l10n.contactTypeEmailDefault,
        subtitle: contact.email!,
        primary: primary,
        sub: sub,
        onTap: () async {
          final uri = Uri.parse('mailto:${contact.email}');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      );
    }
    if (contact.hasLink) {
      final raw = contact.link!.trim();
      final display = raw.length > 48 ? '${raw.substring(0, 45)}…' : raw;
      return _ContactCard(
        icon: Icons.language_rounded,
        iconBg: const Color(0xFF7C3AED),
        title: contact.label.isNotEmpty ? contact.label : l10n.contactTypeWebsiteDefault,
        subtitle: display,
        primary: primary,
        sub: sub,
        onTap: () async {
          final uri = _linkUri(raw);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color primary;
  final Color sub;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sub.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconBg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sub,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 18, color: sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _normalizePhoneForDial(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  if (t.startsWith('+')) {
    final rest = t.substring(1).replaceAll(RegExp(r'\D'), '');
    return rest.isEmpty ? '' : '+$rest';
  }
  return t.replaceAll(RegExp(r'\D'), '');
}

Uri _linkUri(String raw) {
  final t = raw.trim();
  if (t.startsWith('http://') || t.startsWith('https://')) {
    return Uri.parse(t);
  }
  return Uri.parse('https://$t');
}