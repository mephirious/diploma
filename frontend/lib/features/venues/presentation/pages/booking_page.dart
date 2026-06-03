import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_required_screen.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../data/models/venue_model.dart';
import '../../data/models/venue_schedule_result_model.dart';
import '../../data/models/promo_model.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/booking_availability.dart';
import '../../data/models/saved_card_model.dart';
import '../../presentation/providers/saved_cards_provider.dart';
import '../../presentation/providers/venue_provider.dart';
import '../../../reservations/data/models/booking_model.dart';
import '../../../reservations/data/repositories/booking_repository.dart';
import '../../../reservations/presentation/providers/reservations_provider.dart';
import '../../../sessions/data/models/session_model_simple.dart';
import '../../../sessions/presentation/providers/sessions_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../payments/data/models/payment_intent_model.dart';
import '../../../payments/data/payment_card_validator.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/widgets/payment_processing_sheet.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedStartTimeProvider = StateProvider<String?>((ref) => null);
final selectedEndTimeProvider = StateProvider<String?>((ref) => null);

/// Selected resource for the current booking (must be set when using BookingPage).
final selectedResourceIdProvider = StateProvider<String?>((ref) => null);

/// Currently applied promo code (PromoModel.id) or null if none applied.
final selectedPromoProvider = StateProvider<PromoModel?>((ref) => null);

// ─────────────────────────────────────────────
// BOOKING PAGE
// ─────────────────────────────────────────────
class BookingPage extends ConsumerStatefulWidget {
  final VenueModel venue;

  /// When set, this resource is pre-selected (e.g. from venue detail "Book" on a resource).
  final String? preselectedResourceId;

  const BookingPage(
      {super.key, required this.venue, this.preselectedResourceId});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final sr =
            await ref.read(venueScheduleResultProvider(widget.venue.id).future);
        if (!mounted) return;
        final id = _pickInitialResourceId(sr);
        ref.read(selectedResourceIdProvider.notifier).state = id;
      } catch (_) {}
    });
  }

  String? _pickInitialResourceId(VenueScheduleResultModel sr) {
    final pre = widget.preselectedResourceId;
    if (pre != null && pre.isNotEmpty) {
      for (final g in sr.groups) {
        final rid = g.resource?.id ?? g.resourceId;
        if (rid == pre && g.isBookable) return pre;
      }
    }
    for (final g in sr.groups) {
      if (g.isBookable) return g.resource?.id ?? g.resourceId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return AuthRequiredScreen(
        title: l10n.bookNow,
        description: l10n.loginToBookDescription,
      );
    }
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedStart = ref.watch(selectedStartTimeProvider);
    final selectedEnd = ref.watch(selectedEndTimeProvider);
    final selectedResourceId = ref.watch(selectedResourceIdProvider);
    final selectedPromo = ref.watch(selectedPromoProvider);
    final scheduleResultAsync =
        ref.watch(venueScheduleResultProvider(widget.venue.id));

    // Promos for the selected resource (key: venueId|resourceId).
    final promoKey = '${widget.venue.id}|${selectedResourceId ?? ''}';
    final promosAsync = selectedResourceId != null
        ? ref.watch(resourcePromosProvider(promoKey))
        : const AsyncValue<List<PromoModel>>.data([]);
    final availablePromos = promosAsync.valueOrNull ?? const [];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sr = scheduleResultAsync.valueOrNull;
    ScheduleResultGroup? selectedGroup;
    if (sr != null && selectedResourceId != null) {
      for (final g in sr.groups) {
        final id = g.resource?.id ?? g.resourceId;
        if (id == selectedResourceId) {
          selectedGroup = g;
          break;
        }
      }
    }

    final opening = selectedGroup != null
        ? openingForCalendarDay(
            selectedGroup,
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          )
        : null;
    final loc =
        selectedGroup != null ? resolveVenueLocation(selectedGroup) : tz.UTC;
    final blocked = selectedGroup != null
        ? blockedLocalHoursForDay(
            selectedGroup,
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            loc,
          )
        : <int>{};

    final tooSoonOrPastStart = pastOrTooSoonStartHours(
      loc,
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final blockedForStart = {...blocked, ...tooSoonOrPastStart};

    final bookedSlotStrings = blockedForStart
        .map((h) => '${h.toString().padLeft(2, '0')}:00')
        .toList();

    if (selectedStart != null && bookedSlotStrings.contains(selectedStart)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(selectedStartTimeProvider.notifier).state = null;
        ref.read(selectedEndTimeProvider.notifier).state = null;
      });
    }

    final startSlotCandidates = <String>[];
    if (opening != null) {
      for (var h = opening.startHour; h < opening.endHour; h++) {
        startSlotCandidates.add('${h.toString().padLeft(2, '0')}:00');
      }
    }

    final availableEndTimes = selectedStart != null
        ? validEndSlotsForStart(selectedStart, opening, blocked)
        : <String>[];

    final duration = (selectedStart != null && selectedEnd != null)
        ? int.parse(selectedEnd.split(':')[0]) -
            int.parse(selectedStart.split(':')[0])
        : 0;

    final hourlyPrices = (selectedGroup != null &&
            selectedStart != null &&
            selectedEnd != null &&
            duration > 0)
        ? hourlyPricesForRange(
            selectedGroup,
            loc,
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            int.parse(selectedStart.split(':').first),
            int.parse(selectedEnd.split(':').first),
          )
        : <int>[];
    final priceLineItems = mergeAdjacentHourPrices(hourlyPrices);
    final rawTotal = hourlyPrices.fold<int>(0, (a, b) => a + b);

    // Apply selected promo discount if conditions are met for the booking date.
    final effectivePromo = () {
      final p = selectedPromo;
      if (p == null || rawTotal == 0 || duration == 0) return null;
      if (!p.isEffectiveForBooking(
        date: selectedDate,
        durationMinutes: duration * 60,
        bookingPriceMinor: rawTotal,
      )) {
        return null;
      }
      return p;
    }();

    final discountedTotal =
        effectivePromo != null ? effectivePromo.applyTo(rawTotal) : rawTotal;
    final discountAmount = rawTotal - discountedTotal;
    final totalPrice = discountedTotal.toDouble();

    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    final sub = isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);

    final String? facilityHeroUrl = () {
      final r = selectedGroup?.resource;
      if (r != null && r.images.isNotEmpty) return r.images.first;
      if (widget.venue.images.isNotEmpty) return widget.venue.images.first;
      return null;
    }();
    final Object heroSwitcherKey =
        '${selectedResourceId ?? 'none'}_${facilityHeroUrl ?? 'empty'}';

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: bg,
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            leading: _BackButton(isDark: isDark),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  SizedBox.expand(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );
                        return FadeTransition(
                          opacity: curved,
                          child: child,
                        );
                      },
                      child: facilityHeroUrl != null
                          ? Image.network(
                              facilityHeroUrl,
                              key: ValueKey<Object>(heroSwitcherKey),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (_, __, ___) =>
                                  _bookingHeroPlaceholder(isDark),
                            )
                          : KeyedSubtree(
                              key: ValueKey<Object>(heroSwitcherKey),
                              child: SizedBox.expand(
                                child: _bookingHeroPlaceholder(isDark),
                              ),
                            ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          bg.withValues(alpha: 0.95),
                        ],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.venue.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF0D1117),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.colorMain),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                            widget.venue.address,
                            style: TextStyle(fontSize: 12, color: sub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── RESOURCE SECTION ──
                _SectionLabel(label: l10n.facility, isDark: isDark),
                const SizedBox(height: 10),
                _ResourceSelector(
                  venueId: widget.venue.id,
                  selectedResourceId: selectedResourceId,
                  isDark: isDark,
                  l10n: l10n,
                  onSelect: (id) {
                    ref.read(selectedResourceIdProvider.notifier).state = id;
                    ref.read(selectedStartTimeProvider.notifier).state = null;
                    ref.read(selectedEndTimeProvider.notifier).state = null;
                    ref.read(selectedPromoProvider.notifier).state = null;
                  },
                ),
                const SizedBox(height: 24),

                // ── DATE SECTION ──
                _SectionLabel(label: l10n.selectDate, isDark: isDark),
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 14,
                    itemBuilder: (context, i) {
                      final date = DateTime.now().add(Duration(days: i));
                      final isSel = selectedDate.day == date.day &&
                          selectedDate.month == date.month;
                      final isToday = i == 0;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(selectedDateProvider.notifier).state = date;
                          ref.read(selectedStartTimeProvider.notifier).state =
                              null;
                          ref.read(selectedEndTimeProvider.notifier).state =
                              null;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 56,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.colorMain : surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                        color: AppColors.colorMain
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4)),
                                  ]
                                : [
                                    if (!isDark)
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2)),
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(date).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: isSel
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : sub,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('d').format(date),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF0D1117)),
                                ),
                              ),
                              if (isToday)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSel
                                        ? Colors.white
                                        : AppColors.colorMain,
                                  ),
                                )
                              else
                                const SizedBox(height: 7),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── TIME SECTION ──
                if (selectedResourceId != null) ...[
                  _SectionLabel(label: l10n.selectTime, isDark: isDark),
                  const SizedBox(height: 6),
                  if (opening == null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.noSlotsThisDay,
                        style: TextStyle(
                          fontSize: 14,
                          color: sub,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.selectStartTimeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: sub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _TimeSlotRow(
                      slots: startSlotCandidates,
                      bookedSlots: bookedSlotStrings,
                      selectedSlot: selectedStart,
                      isDark: isDark,
                      onSelect: (t) {
                        HapticFeedback.selectionClick();
                        ref.read(selectedStartTimeProvider.notifier).state = t;
                        ref.read(selectedEndTimeProvider.notifier).state = null;
                      },
                    ),
                    if (selectedStart != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          l10n.selectEndTimeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: sub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _TimeSlotRow(
                        slots: availableEndTimes,
                        bookedSlots: const [],
                        selectedSlot: selectedEnd,
                        isDark: isDark,
                        onSelect: (t) {
                          HapticFeedback.selectionClick();
                          ref.read(selectedEndTimeProvider.notifier).state = t;
                        },
                      ),
                    ],
                  ],
                ],

                // ── SELECTED RANGE SUMMARY ──
                if (selectedStart != null) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _TimeRangeBanner(
                      start: selectedStart,
                      end: selectedEnd,
                      duration: duration,
                      l10n: l10n,
                      isDark: isDark,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── PROMO SECTION ──
                if (selectedResourceId != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PromoSection(
                      promos: availablePromos,
                      selectedDate: selectedDate,
                      selectedPromo: selectedPromo,
                      duration: duration,
                      rawTotalMinor: rawTotal,
                      isDark: isDark,
                      l10n: l10n,
                      onSelect: (p) {
                        ref.read(selectedPromoProvider.notifier).state = p;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── PRICE SUMMARY ROW ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _PriceSummaryCard(
                    lineItems: priceLineItems,
                    duration: duration,
                    rawTotal: rawTotal.toDouble(),
                    totalPrice: totalPrice,
                    discountAmount: discountAmount.toDouble(),
                    appliedPromo: effectivePromo,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),

      // ── BOTTOM CTA ──
      bottomNavigationBar: _BookingBottomBar(
        totalPrice: totalPrice,
        enabled: selectedResourceId != null &&
            selectedStart != null &&
            selectedEnd != null &&
            opening != null,
        isDark: isDark,
        l10n: l10n,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentPage(
                venue: widget.venue,
                resourceId: selectedResourceId,
                date: selectedDate,
                time: selectedStart!,
                duration: duration,
                totalPrice: totalPrice,
                bookingTimezone: resolveBookingTimezoneIana(
                  venueTimezone: widget.venue.timezone,
                  scheduleGroup: selectedGroup,
                ),
              ),
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAYMENT PAGE
// ─────────────────────────────────────────────
class PaymentPage extends ConsumerStatefulWidget {
  final VenueModel venue;

  /// Selected resource for the booking (required by backend).
  final String? resourceId;
  final DateTime date;
  final String time;
  final int duration;
  final double totalPrice;

  /// IANA timezone sent with POST /bookings (venue or schedule-derived).
  final String bookingTimezone;

  /// When set, only charge this booking (no POST /bookings).
  final BookingModel? payExistingBooking;
  final SessionModelSimple? paySession;

  const PaymentPage({
    super.key,
    required this.venue,
    this.resourceId,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalPrice,
    required this.bookingTimezone,
    this.payExistingBooking,
    this.paySession,
  });

  /// Pay an existing unpaid booking from booking details.
  factory PaymentPage.forExistingBooking({
    required BookingModel booking,
    required VenueModel venue,
  }) {
    final start = booking.startAt ?? DateTime.now();
    return PaymentPage(
      payExistingBooking: booking,
      venue: venue,
      resourceId: booking.resourceId,
      date: DateTime(start.year, start.month, start.day),
      time: booking.startTimeStr,
      duration: booking.durationHours,
      totalPrice: booking.priceTotalInt.toDouble(),
      bookingTimezone: booking.timezone ?? 'Asia/Almaty',
    );
  }

  factory PaymentPage.forSession({
    required SessionModelSimple session,
    required VenueModel venue,
  }) {
    return PaymentPage(
      paySession: session,
      venue: venue,
      resourceId: session.resourceId,
      date: DateTime(session.date.year, session.date.month, session.date.day),
      time: session.timeSlots.isNotEmpty
          ? session.timeSlots.first.split(' ').first
          : DateFormat('HH:mm').format(session.date),
      duration: _sessionDurationHours(session),
      totalPrice: session.pricePerPlayer,
      bookingTimezone: 'Asia/Almaty',
    );
  }

  bool get _isExistingBookingPayment => payExistingBooking != null;
  bool get _isSessionPayment => paySession != null;

  static int _sessionDurationHours(SessionModelSimple session) {
    if (session.timeSlots.isEmpty) return 1;
    final parts = session.timeSlots.first.split('–');
    if (parts.length < 2) return 1;
    final start = _parseHourMinute(parts[0]);
    final end = _parseHourMinute(parts[1]);
    if (start == null || end == null) return 1;
    var minutes = end.$1 * 60 + end.$2 - (start.$1 * 60 + start.$2);
    if (minutes <= 0) minutes += 24 * 60;
    return (minutes / 60).ceil().clamp(1, 24);
  }

  static (int, int)? _parseHourMinute(String raw) {
    final pieces = raw.trim().split(':');
    if (pieces.length < 2) return null;
    final hour = int.tryParse(pieces[0]);
    final minute = int.tryParse(pieces[1].replaceAll(RegExp(r'[^0-9]'), ''));
    if (hour == null || minute == null) return null;
    return (hour, minute);
  }

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedPaymentMethod = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedCards = ref.read(savedCardsProvider);
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      setState(() {
        if (savedCards.isNotEmpty) {
          _selectedPaymentMethod = 'card_${savedCards.first.id}';
        } else if (isIOS) {
          _selectedPaymentMethod = 'apple_pay';
        } else {
          _selectedPaymentMethod = 'google_pay';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedCards = ref.watch(savedCardsProvider);
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    final sub = isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (_selectedPaymentMethod.isEmpty) {
      return Scaffold(
          backgroundColor: bg,
          body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: _BackButton(isDark: isDark),
        title: Text(
          l10n.payment,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0D1117),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── BOOKING SUMMARY CARD ──
            _BookingSummaryCard(
              venue: widget.venue,
              date: widget.date,
              time: widget.time,
              duration: widget.duration,
              totalPrice: widget.totalPrice,
              title: widget._isSessionPayment
                  ? (widget.paySession?.sportType ?? 'Session')
                  : null,
              notice: widget._isSessionPayment
                  ? 'You are paying to join a shared session, not booking the venue privately.'
                  : null,
              isDark: isDark,
              surface: surface,
              sub: sub,
              l10n: l10n,
            ),

            const SizedBox(height: 28),

            // ── PAYMENT METHOD HEADER ──
            Text(
              l10n.paymentMethod,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // ── PAYMENT OPTIONS (stacked vertically) ──
            if (isIOS) ...[
              _FullWidthPayTile(
                selected: _selectedPaymentMethod == 'apple_pay',
                bgColor: const Color(0xFF000000),
                selectedBorderColor: AppColors.colorMain,
                child: _ApplePayContent(payLabel: l10n.paymentPayButton),
                onTap: () =>
                    setState(() => _selectedPaymentMethod = 'apple_pay'),
              ),
              const SizedBox(height: 10),
            ],
            _FullWidthPayTile(
              selected: _selectedPaymentMethod == 'google_pay',
              bgColor: Colors.white,
              unselectedBorderColor:
                  isDark ? const Color(0xFF30363D) : const Color(0xFFE8ECF0),
              selectedBorderColor: AppColors.colorMain,
              child: _GooglePayContent(payLabel: l10n.paymentPayButton),
              onTap: () =>
                  setState(() => _selectedPaymentMethod = 'google_pay'),
            ),
            const SizedBox(height: 10),
            _FullWidthPayTile(
              selected: _selectedPaymentMethod == 'kaspi',
              bgColor: const Color(0xFFE31E24),
              selectedBorderColor: AppColors.colorMain,
              checkBgColor: Colors.white,
              checkIconColor: const Color(0xFFE31E24),
              child: const _KaspiContent(),
              onTap: () => setState(() => _selectedPaymentMethod = 'kaspi'),
            ),

            const SizedBox(height: 20),

            // ── SAVED CARDS DROPDOWN ──
            _SavedCardsDropdown(
              savedCards: savedCards,
              selectedPaymentMethod: _selectedPaymentMethod,
              isDark: isDark,
              surface: surface,
              sub: sub,
              l10n: l10n,
              onSelectCard: (id) => setState(() => _selectedPaymentMethod = id),
              onDeleteCard: (cardId) {
                ref.read(savedCardsProvider.notifier).removeCard(cardId);
                if (_selectedPaymentMethod == 'card_$cardId') {
                  final cards = ref.read(savedCardsProvider);
                  setState(() {
                    _selectedPaymentMethod =
                        cards.isEmpty ? 'google_pay' : 'card_${cards.first.id}';
                  });
                }
              },
              onAddCard: () => _showAddCardSheet(context),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
      bottomNavigationBar: _PaymentBottomBar(
        totalPrice: widget.totalPrice,
        isDark: isDark,
        l10n: l10n,
        onTap: () => _confirmPayment(context),
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final bankNameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    String? cardError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Text(l10n.addNewCard,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 20),
                  _StyledTextField(
                      controller: cardNumberController,
                      label: l10n.cardNumber,
                      hint: '1234  5678  9012  3456',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      isDark: isDark),
                  const SizedBox(height: 12),
                  _StyledTextField(
                      controller: bankNameController,
                      label: l10n.bankCardBrandLabel,
                      hint: l10n.bankCardBrandHint,
                      icon: Icons.account_balance_rounded,
                      isDark: isDark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _StyledTextField(
                              controller: expiryController,
                              label: l10n.expiryDate,
                              hint: 'MM/YY',
                              icon: Icons.date_range_rounded,
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              isDark: isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StyledTextField(
                              controller: cvvController,
                              label: l10n.cvv,
                              hint: '•••',
                              icon: Icons.lock_outline_rounded,
                              keyboardType: TextInputType.number,
                              obscure: true,
                              maxLength: 4,
                              isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.savedCardLocalOnlyNotice,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFF6E7A8A),
                    ),
                  ),
                  if (cardError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      cardError!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorError,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final validation = PaymentCardValidator.validate(
                          number: cardNumberController.text,
                          expiry: expiryController.text,
                          cvv: cvvController.text,
                        );
                        if (!validation.isValid) {
                          setSheetState(() {
                            cardError =
                                _cardValidationMessage(l10n, validation.field);
                          });
                          return;
                        }
                        final number = cardNumberController.text
                            .replaceAll(RegExp(r'\D'), '');
                        if (number.length >= 4) {
                          final lastFour = number.substring(number.length - 4);
                          final expiry = expiryController.text.split('/');
                          final card = SavedCardModel(
                            id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                            lastFourDigits: lastFour,
                            brand: bankNameController.text.isNotEmpty
                                ? bankNameController.text
                                : 'card',
                            bankName: bankNameController.text.isNotEmpty
                                ? bankNameController.text
                                : null,
                            expiryMonth: expiry.isNotEmpty ? expiry[0] : '00',
                            expiryYear: expiry.length >= 2 ? expiry[1] : '00',
                          );
                          ref.read(savedCardsProvider.notifier).addCard(card);
                          setState(
                              () => _selectedPaymentMethod = 'card_${card.id}');
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(l10n.save,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _cardValidationMessage(AppLocalizations l10n, String? field) {
    return switch (field) {
      'number' => l10n.cardNumberInvalid,
      'expiry' => l10n.cardExpiryInvalid,
      'cvv' => l10n.cardCvvInvalid,
      _ => l10n.cardDetailsInvalid,
    };
  }

  Future<void> _confirmPayment(BuildContext context) async {
    if (widget._isSessionPayment) {
      await _confirmPaymentForSession(context);
    } else if (widget._isExistingBookingPayment) {
      await _confirmPaymentForExistingBooking(context);
    } else {
      await _confirmPaymentForNewBooking(context);
    }
  }

  Future<void> _runPaymentFlow(
    BuildContext context,
    AppLocalizations l10n, {
    required Future<PaymentCreateRequest> Function() buildPaymentRequest,
    bool bookingAlreadyExists = false,
  }) async {
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentProcessingSheet(),
    );

    var bookingCreated = bookingAlreadyExists;
    try {
      final request = await buildPaymentRequest();
      bookingCreated = true;

      final intent = await ref.read(paymentRepositoryProvider).createPayment(
            request,
          );

      final result = await ref
          .read(paymentRepositoryProvider)
          .pollUntilTerminal(intent.id);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (!widget._isExistingBookingPayment && !widget._isSessionPayment) {
        resetGuestBookingLists(ref);
      }
      if (widget._isSessionPayment) {
        ref.invalidate(sessionsListProvider);
      }
      ref.invalidate(venueScheduleResultProvider(widget.venue.id));

      if (result.isSucceeded) {
        _showSuccessDialog(context, l10n);
      } else {
        _showPaymentFailedDialog(context, l10n);
      }
    } on PaymentPollTimeoutException {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!widget._isExistingBookingPayment && !widget._isSessionPayment) {
        resetGuestBookingLists(ref);
      }
      if (!context.mounted) return;
      _showPaymentFailedDialog(context, l10n);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (bookingCreated) {
        if (!widget._isExistingBookingPayment && !widget._isSessionPayment) {
          resetGuestBookingLists(ref);
        }
        _showPaymentFailedDialog(context, l10n);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingFailedMessage('$e')),
            backgroundColor: AppColors.colorError,
          ),
        );
      }
    }
  }

  Future<void> _confirmPaymentForExistingBooking(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final booking = widget.payExistingBooking!;
    await _runPaymentFlow(
      context,
      l10n,
      bookingAlreadyExists: true,
      buildPaymentRequest: () async => PaymentCreateRequest(
        bookingId: booking.id,
        paymentMethod: apiPaymentMethodFromSelection(_selectedPaymentMethod),
      ),
    );
  }

  Future<void> _confirmPaymentForSession(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final session = widget.paySession!;
    await _runPaymentFlow(
      context,
      l10n,
      bookingAlreadyExists: true,
      buildPaymentRequest: () async => PaymentCreateRequest(
        paymentType: 'session',
        sessionId: session.id,
        paymentMethod: apiPaymentMethodFromSelection(_selectedPaymentMethod),
      ),
    );
  }

  Future<void> _confirmPaymentForNewBooking(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final parts = widget.time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final startAt = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      hour,
      minute,
    );
    final endAt = startAt.add(Duration(hours: widget.duration));

    final auth = ref.read(authProvider);
    final userId = auth.authUser?.sub ?? auth.user?.id;

    final request = BookingCreateRequest(
      venueId: widget.venue.id,
      resourceId: widget.resourceId,
      startAt: startAt,
      endAt: endAt,
      timezone: widget.bookingTimezone,
      priceTotal: widget.totalPrice.toInt().toString(),
      currency: 'KZT',
      userId: userId,
      idempotencyKey: 'pay_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _runPaymentFlow(
      context,
      l10n,
      buildPaymentRequest: () async {
        final unavailable = await _selectedSlotUnavailable(startAt, endAt);
        if (unavailable) {
          ref.invalidate(venueScheduleResultProvider(widget.venue.id));
          throw Exception(l10n.slotJustBecameUnavailable);
        }
        final created =
            await ref.read(bookingRepositoryProvider).createBooking(request);
        ref.invalidate(venueScheduleResultProvider(widget.venue.id));
        return PaymentCreateRequest(
          bookingId: created.id,
          paymentMethod: apiPaymentMethodFromSelection(_selectedPaymentMethod),
        );
      },
    );
  }

  Future<bool> _selectedSlotUnavailable(
      DateTime startAt, DateTime endAt) async {
    final resourceId = widget.resourceId;
    if (resourceId == null || resourceId.isEmpty) return true;
    final schedule = await ref.read(venueRepositoryProvider).getScheduleResult(
          widget.venue.id,
          resourceId: resourceId,
          from: startAt,
          to: endAt,
        );
    ScheduleResultGroup? group;
    for (final g in schedule.groups) {
      final id = g.resource?.id ?? g.resourceId;
      if (id == resourceId) {
        group = g;
        break;
      }
    }
    if (group == null) return true;
    final loc = resolveVenueLocation(group);
    final blocked = blockedLocalHoursForDay(
      group,
      widget.date.year,
      widget.date.month,
      widget.date.day,
      loc,
    );
    for (var h = startAt.hour; h < endAt.hour; h++) {
      if (blocked.contains(h)) return true;
    }
    return false;
  }

  void _navigateToMyBookings() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    ref.read(selectedIndexProvider.notifier).state = 1;
    resetGuestBookingLists(ref);
  }

  void _finishPaymentFlow(BuildContext context) {
    if (widget._isExistingBookingPayment) {
      Navigator.of(context).pop();
    }
  }

  void _showPaymentFailedDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.colorError.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.colorError,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.paymentFailedTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.paymentFailedMessage,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (widget._isExistingBookingPayment) {
                _finishPaymentFlow(context);
              } else if (widget._isSessionPayment) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              } else {
                _navigateToMyBookings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget._isExistingBookingPayment
                  ? l10n.bookingDetails
                  : widget._isSessionPayment
                      ? 'Sessions'
                      : l10n.myBookings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.colorMain,
                    AppColors.colorMain.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.colorMain.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
                widget._isSessionPayment
                    ? 'Session joined'
                    : l10n.bookingConfirmed,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
                widget._isSessionPayment
                    ? 'Your payment was successful and your place in this session is confirmed.'
                    : l10n.bookingSuccess,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF8B949E)
                        : const Color(0xFF6E7A8A)),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          if (!widget._isExistingBookingPayment && !widget._isSessionPayment)
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Text(l10n.backToHome,
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontWeight: FontWeight.w600)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget._isExistingBookingPayment) {
                _finishPaymentFlow(context);
              } else if (widget._isSessionPayment) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              } else {
                Navigator.of(context).popUntil((r) => r.isFirst);
                ref.read(selectedIndexProvider.notifier).state = 1;
              }
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text(
              widget._isExistingBookingPayment
                  ? l10n.bookingDetails
                  : widget._isSessionPayment
                      ? 'Sessions'
                      : l10n.viewBooking,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENTS
// ─────────────────────────────────────────────

Widget _bookingHeroPlaceholder(bool isDark) {
  return ColoredBox(
    color: isDark ? const Color(0xFF1C2128) : const Color(0xFFE8ECF0),
    child: Center(
      child: Icon(
        Icons.sports,
        size: 64,
        color: AppColors.colorMain.withValues(alpha: 0.3),
      ),
    ),
  );
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: isDark ? Colors.white : const Color(0xFF0D1117)),
      ),
    );
  }
}

class _ResourceSelector extends ConsumerWidget {
  final String venueId;
  final String? selectedResourceId;
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String?) onSelect;

  const _ResourceSelector({
    required this.venueId,
    required this.selectedResourceId,
    required this.isDark,
    required this.l10n,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(venueScheduleResultProvider(venueId));
    return scheduleAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
            height: 52,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          l10n.unableToLoadFacilities,
          style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14),
        ),
      ),
      data: (sr) {
        final groups = sr.groups.where((g) => g.isBookable).toList();
        if (groups.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.noFacilitiesListed,
              style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14),
            ),
          );
        }
        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final g = groups[i];
              final id = g.resource?.id ?? g.resourceId ?? '';
              final name = g.resource?.displayName ??
                  g.resourceId ??
                  l10n.resourcePickerFallback;
              final isSel = selectedResourceId == id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onSelect(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.colorMain
                          : (isDark ? const Color(0xFF161B22) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel
                            ? AppColors.colorMain
                            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSel
                              ? Colors.white
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF0D1117)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : const Color(0xFF0D1117),
          )),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final List<String> slots;
  final List<String> bookedSlots;
  final String? selectedSlot;
  final bool isDark;
  final void Function(String) onSelect;

  const _TimeSlotRow({
    required this.slots,
    required this.bookedSlots,
    required this.selectedSlot,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: slots.length,
        itemBuilder: (context, i) {
          final time = slots[i];
          final isBooked = bookedSlots.contains(time);
          final isSel = selectedSlot == time;

          return GestureDetector(
            onTap: isBooked ? null : () => onSelect(time),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isBooked
                    ? (isDark
                        ? const Color(0xFF1C2128)
                        : const Color(0xFFF0F0F0))
                    : isSel
                        ? AppColors.colorMain
                        : surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBooked
                      ? Colors.transparent
                      : isSel
                          ? AppColors.colorMain
                          : (isDark ? Colors.white12 : const Color(0xFFE8ECF0)),
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                            color: AppColors.colorMain.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isBooked
                      ? (isDark ? Colors.white24 : Colors.grey[400])
                      : isSel
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF3D4B5C)),
                  decoration: isBooked ? TextDecoration.lineThrough : null,
                  decorationColor: isDark ? Colors.white24 : Colors.grey[400],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeRangeBanner extends StatelessWidget {
  final String? start;
  final String? end;
  final int duration;
  final AppLocalizations l10n;
  final bool isDark;

  const _TimeRangeBanner({
    required this.start,
    required this.end,
    required this.duration,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.colorMain.withValues(alpha: isDark ? 0.2 : 0.08),
            AppColors.colorMain.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.colorMain.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.colorMain.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.schedule_rounded,
                color: AppColors.colorMain, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: end != null
                ? RichText(
                    text: TextSpan(
                    style: TextStyle(fontSize: 14, color: AppColors.colorMain),
                    children: [
                      TextSpan(
                          text: '$start  →  $end',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      TextSpan(
                          text:
                              '  ·  $duration ${duration == 1 ? l10n.hour : l10n.hours}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  AppColors.colorMain.withValues(alpha: 0.7))),
                    ],
                  ))
                : Text('$start  →  ?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.colorMain)),
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  /// Consecutive runs of the same hourly rate: `(rate, hours)`.
  final List<(int, int)> lineItems;
  final int duration;
  final double rawTotal;
  final double totalPrice;
  final double discountAmount;
  final PromoModel? appliedPromo;
  final bool isDark;
  final AppLocalizations l10n;

  const _PriceSummaryCard({
    required this.lineItems,
    required this.duration,
    required this.rawTotal,
    required this.totalPrice,
    this.discountAmount = 0,
    this.appliedPromo,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;

    final rateRows = <Widget>[];
    if (lineItems.isEmpty) {
      rateRows.add(
        _PriceRow(
          label: '0 ₸ × $duration ${duration == 1 ? l10n.hour : l10n.hours}',
          value: '${totalPrice.toInt()} ₸',
          isDark: isDark,
          isTotal: false,
        ),
      );
    } else {
      for (var i = 0; i < lineItems.length; i++) {
        if (i > 0) rateRows.add(const SizedBox(height: 8));
        final (rate, hours) = lineItems[i];
        final unit = hours == 1 ? l10n.hour : l10n.hours;
        rateRows.add(
          _PriceRow(
            label: '$rate ₸ × $hours $unit',
            value: '${rate * hours} ₸',
            isDark: isDark,
            isTotal: false,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
      ),
      child: Column(
        children: [
          ...rateRows,
          if (duration > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                  color: isDark ? Colors.white12 : const Color(0xFFEEF0F4),
                  height: 1),
            ),
            // Show subtotal + discount lines when a promo is applied.
            if (appliedPromo != null && discountAmount > 0) ...[
              _PriceRow(
                label: l10n.subtotal,
                value: '${rawTotal.toInt()} ₸',
                isDark: isDark,
                isTotal: false,
              ),
              const SizedBox(height: 6),
              _PriceRow(
                label: '🏷 ${appliedPromo!.name}',
                value: '−${discountAmount.toInt()} ₸',
                isDark: isDark,
                isTotal: false,
                isDiscount: true,
              ),
              const SizedBox(height: 10),
            ],
            _PriceRow(
              label: l10n.totalPrice,
              value: '${totalPrice.toInt()} ₸',
              isDark: isDark,
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isDark, isTotal;
  final bool isDiscount;
  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.isTotal,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final sub = isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);
    final discountGreen =
        isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? discountGreen
                  : isTotal
                      ? (isDark ? Colors.white : const Color(0xFF0D1117))
                      : sub,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.w800,
            color: isDiscount
                ? discountGreen
                : isTotal
                    ? AppColors.colorMain
                    : (isDark ? Colors.white : const Color(0xFF0D1117)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo section: selectable promos + always-visible code entry
// ─────────────────────────────────────────────────────────────────────────────

String _promoConditionsText(PromoModel p, {String? locale, DateTime? onDate}) {
  final parts = <String>[];
  if (p.minDurationMinutes != null) {
    parts.add('Min ${p.minDurationMinutes! ~/ 60}h booking required');
  }
  if (p.minBookingPriceMinor != null) {
    parts.add('Min ${p.minBookingPriceMinor! ~/ 100} ₸ required');
  }
  final daysLabel = p.applicableDaysLabel(locale: locale);
  if (daysLabel.isNotEmpty) {
    parts.add('Valid on $daysLabel');
  }
  if (onDate != null &&
      !p.appliesAnyDay &&
      !p.isApplicableOnDate(onDate)) {
    parts.add('Not valid on ${DateFormat.E(locale).format(onDate)}');
  }
  return parts.join(' · ');
}

class _PromoSection extends StatefulWidget {
  final List<PromoModel> promos;
  final DateTime selectedDate;
  final PromoModel? selectedPromo;
  final int duration; // in hours
  final int rawTotalMinor;
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(PromoModel?) onSelect;

  const _PromoSection({
    required this.promos,
    required this.selectedDate,
    required this.selectedPromo,
    required this.duration,
    required this.rawTotalMinor,
    required this.isDark,
    required this.l10n,
    required this.onSelect,
  });

  @override
  State<_PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<_PromoSection> {
  final _codeController = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool _isPromoEffective(PromoModel p) {
    return p.isEffectiveForBooking(
      date: widget.selectedDate,
      durationMinutes: widget.duration * 60,
      bookingPriceMinor: widget.rawTotalMinor,
    );
  }

  String _conditionsText(PromoModel p) {
    return _promoConditionsText(
      p,
      locale: Localizations.localeOf(context).toString(),
      onDate: widget.selectedDate,
    );
  }

  Future<void> _showConditionsNotMetDialog(PromoModel p) {
    final conditions = _conditionsText(p);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l10n.promoConditionsNotMet),
        content: Text(
          conditions.isNotEmpty ? conditions : widget.l10n.promoConditionsNotMet,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
  }

  void _handlePromoSelect(PromoModel p, {required bool isSelected}) {
    final next = isSelected ? null : p;
    if (next != null && !_isPromoEffective(next)) {
      unawaited(_showConditionsNotMetDialog(next));
    }
    widget.onSelect(next);
  }

  void _applyPromoCode() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final codePromos =
        widget.promos.where((p) => !p.isAutoApplied).toList();
    PromoModel? found;
    for (final p in codePromos) {
      if ((p.code?.toUpperCase() ?? '') == code) {
        found = p;
        break;
      }
    }

    if (found == null) {
      setState(() => _codeError = widget.l10n.promoCodeInvalid);
      return;
    }

    setState(() => _codeError = null);
    if (!_isPromoEffective(found)) {
      unawaited(_showConditionsNotMetDialog(found));
    }
    _codeController.clear();
    widget.onSelect(found);
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? const Color(0xFF161B22) : Colors.white;
    final sub =
        widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);

    final selectablePromos = widget.promos
        .where(
          (p) => p.isAutoApplied && p.isValidForBookingDate(widget.selectedDate),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_rounded,
                  size: 16, color: AppColors.colorMain),
              const SizedBox(width: 8),
              Text(
                widget.l10n.promoSectionTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : const Color(0xFF0D1117),
                ),
              ),
            ],
          ),

          // Selectable (non-code) promos — shown before code entry.
          if (selectablePromos.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...selectablePromos.map((p) {
              final isSelected = widget.selectedPromo?.id == p.id;
              return _PromoTile(
                promo: p,
                isSelected: isSelected,
                isDark: widget.isDark,
                sub: sub,
                conditionsText: _conditionsText(p),
                onTap: () => _handlePromoSelect(p, isSelected: isSelected),
              );
            }),
          ],

          // Code entry — always visible regardless of available promos.
          const SizedBox(height: 12),
          Text(
            widget.l10n.promoEnterCode,
            style: TextStyle(
              fontSize: 13,
              color: sub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: widget.l10n.promoCodeHint,
                    errorText: _codeError,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    isDense: true,
                    filled: true,
                    fillColor: widget.isDark
                        ? const Color(0xFF0D1117)
                        : const Color(0xFFF6F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _applyPromoCode(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.colorMain,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _applyPromoCode,
                child: Text(widget.l10n.promoApply),
              ),
            ],
          ),

          // Applied code promo — shown after successful code entry (not in list).
          if (widget.selectedPromo != null &&
              !widget.selectedPromo!.isAutoApplied) ...[
            const SizedBox(height: 8),
            _PromoTile(
              promo: widget.selectedPromo!,
              isSelected: true,
              isDark: widget.isDark,
              sub: sub,
              conditionsText: _conditionsText(widget.selectedPromo!),
              onTap: () {},
            ),
          ],

          // Remove applied / selected promo.
          if (widget.selectedPromo != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => widget.onSelect(null),
              child: Row(
                children: [
                  Icon(Icons.remove_circle_outline_rounded,
                      size: 16, color: sub),
                  const SizedBox(width: 6),
                  Text(
                    widget.l10n.promoRemove,
                    style: TextStyle(
                      fontSize: 13,
                      color: sub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  final PromoModel promo;
  final bool isSelected;
  final bool isDark;
  final Color sub;
  final String conditionsText;
  final VoidCallback onTap;

  const _PromoTile({
    required this.promo,
    required this.isSelected,
    required this.isDark,
    required this.sub,
    required this.conditionsText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFE8ECF0);
    final hasConditions = conditionsText.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.colorMain.withValues(alpha: isDark ? 0.18 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.colorMain : border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF3D71)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                promo.discountLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0D1117),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasConditions)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        conditionsText,
                        style: TextStyle(fontSize: 11, color: sub),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.colorMain),
          ],
        ),
      ),
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  final double totalPrice;
  final bool enabled;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _BookingBottomBar({
    required this.totalPrice,
    required this.enabled,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          if (totalPrice > 0) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bookingTotalLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF8B949E)
                            : const Color(0xFF6E7A8A))),
                Text('${totalPrice.toInt()} ₸',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color:
                            isDark ? Colors.white : const Color(0xFF0D1117))),
              ],
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 54,
              child: ElevatedButton(
                onPressed: enabled ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled
                      ? AppColors.colorMain
                      : (isDark ? Colors.white12 : const Color(0xFFE8ECF0)),
                  foregroundColor: enabled
                      ? Colors.white
                      : (isDark ? Colors.white38 : Colors.grey[400]),
                  elevation: enabled ? 0 : 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.proceedToPayment,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment components ──

class _BookingSummaryCard extends StatelessWidget {
  final VenueModel venue;
  final DateTime date;
  final String time;
  final int duration;
  final double totalPrice;
  final String? title;
  final String? notice;
  final bool isDark;
  final Color surface;
  final Color sub;
  final AppLocalizations l10n;

  const _BookingSummaryCard({
    required this.venue,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalPrice,
    this.title,
    this.notice,
    required this.isDark,
    required this.surface,
    required this.sub,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: venue.images.isNotEmpty
                      ? Image.network(
                          venue.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.colorMain.withValues(alpha: 0.15),
                            child: Icon(Icons.sports,
                                size: 32,
                                color:
                                    AppColors.colorMain.withValues(alpha: 0.5)),
                          ),
                        )
                      : Container(
                          color: AppColors.colorMain.withValues(alpha: 0.15),
                          child: Icon(Icons.sports,
                              size: 32,
                              color:
                                  AppColors.colorMain.withValues(alpha: 0.5)),
                        ),
                ),
                Positioned.fill(
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ))),
                Positioned(
                    left: 16,
                    bottom: 12,
                    right: 16,
                    child: Text(
                      title ?? venue.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(
                    icon: Icons.calendar_today_rounded,
                    label: l10n.date,
                    value: DateFormat('EEE, MMM d, yyyy').format(date),
                    sub: sub,
                    isDark: isDark),
                const SizedBox(height: 10),
                _SummaryRow(
                    icon: Icons.schedule_rounded,
                    label: l10n.time,
                    value: time,
                    sub: sub,
                    isDark: isDark),
                const SizedBox(height: 10),
                _SummaryRow(
                    icon: Icons.timelapse_rounded,
                    label: l10n.duration,
                    value:
                        '$duration ${duration == 1 ? l10n.hour : l10n.hours}',
                    sub: sub,
                    isDark: isDark),
                if (notice != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.colorMain.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      notice!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D1117),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                      color: isDark ? Colors.white12 : const Color(0xFFEEF0F4),
                      height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalPrice,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0D1117))),
                    Text('${totalPrice.toInt()} ₸',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.colorMain)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color sub;
  final bool isDark;

  const _SummaryRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.sub,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.colorMain.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text('$label  ', style: TextStyle(fontSize: 13, color: sub)),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0D1117)),
                textAlign: TextAlign.end)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FULL-WIDTH PAYMENT TILE (replaces row of small tiles)
// ─────────────────────────────────────────────
class _FullWidthPayTile extends StatelessWidget {
  final bool selected;
  final Color bgColor;
  final Color selectedBorderColor;
  final Color? unselectedBorderColor;
  final Color? checkBgColor;
  final Color? checkIconColor;
  final Widget child;
  final VoidCallback onTap;

  const _FullWidthPayTile({
    required this.selected,
    required this.bgColor,
    required this.selectedBorderColor,
    this.unselectedBorderColor,
    this.checkBgColor,
    this.checkIconColor,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 58,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? selectedBorderColor
                : (unselectedBorderColor ?? bgColor.withValues(alpha: 0.3)),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: selectedBorderColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Stack(
          children: [
            Center(child: child),
            if (selected)
              Positioned(
                top: 8,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checkBgColor ?? selectedBorderColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4)
                    ],
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 13, color: checkIconColor ?? Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SAVED CARDS ANIMATED DROPDOWN
// ─────────────────────────────────────────────
class _SavedCardsDropdown extends StatefulWidget {
  final List<SavedCardModel> savedCards;
  final String selectedPaymentMethod;
  final bool isDark;
  final Color surface;
  final Color sub;
  final AppLocalizations l10n;
  final void Function(String) onSelectCard;
  final void Function(String) onDeleteCard;
  final VoidCallback onAddCard;

  const _SavedCardsDropdown({
    required this.savedCards,
    required this.selectedPaymentMethod,
    required this.isDark,
    required this.surface,
    required this.sub,
    required this.l10n,
    required this.onSelectCard,
    required this.onDeleteCard,
    required this.onAddCard,
  });

  @override
  State<_SavedCardsDropdown> createState() => _SavedCardsDropdownState();
}

class _SavedCardsDropdownState extends State<_SavedCardsDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  SavedCardModel? get _selectedCard {
    if (!widget.selectedPaymentMethod.startsWith('card_')) return null;
    try {
      return widget.savedCards.firstWhere(
        (c) => 'card_${c.id}' == widget.selectedPaymentMethod,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = widget.savedCards.isNotEmpty;
    final selectedCard = _selectedCard;

    // Slightly darker than surface for the dropdown
    final headerColor =
        widget.isDark ? const Color(0xFF11161D) : const Color(0xFFF0F2F5);
    final panelColor =
        widget.isDark ? const Color(0xFF0F1419) : const Color(0xFFECEFF3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header / Toggle Button ──
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(_isExpanded ? 18 : 16),
              border: Border.all(
                color: selectedCard != null
                    ? AppColors.colorMain.withValues(alpha: 0.4)
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFDDE0E6)),
                width: selectedCard != null ? 1.5 : 1,
              ),
              boxShadow: [
                if (!widget.isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Card icon
                Container(
                  width: 38,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: selectedCard != null
                        ? AppColors.colorMain.withValues(alpha: 0.15)
                        : (widget.isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE4E7EC)),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 18,
                    color:
                        selectedCard != null ? AppColors.colorMain : widget.sub,
                  ),
                ),
                const SizedBox(width: 12),
                // Label
                Expanded(
                  child: selectedCard != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCard.bankName ?? selectedCard.brand,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF0D1117),
                              ),
                            ),
                            Text(
                              '••••  ${selectedCard.lastFourDigits}',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.sub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          hasCards
                              ? widget.l10n.otherBankCards
                              : widget.l10n.paymentMyCards,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF0D1117),
                          ),
                        ),
                ),
                // Card count badge
                if (hasCards)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.colorMain.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.savedCards.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.colorMain,
                      ),
                    ),
                  ),
                // Chevron with rotation
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: widget.isDark
                        ? Colors.white54
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expandable Card List ──
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFDDE0E6),
                  ),
                  boxShadow: [
                    if (!widget.isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card items
                    if (hasCards)
                      ...widget.savedCards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final card = entry.value;
                        final isSelected =
                            widget.selectedPaymentMethod == 'card_${card.id}';
                        final isLast = index == widget.savedCards.length - 1;

                        return Column(
                          children: [
                            _DropdownCardItem(
                              card: card,
                              isSelected: isSelected,
                              isDark: widget.isDark,
                              sub: widget.sub,
                              onSelect: () {
                                HapticFeedback.selectionClick();
                                widget.onSelectCard('card_${card.id}');
                                // Auto-collapse after selection
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  if (mounted) _toggle();
                                });
                              },
                              onDelete: () => widget.onDeleteCard(card.id),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                indent: 56,
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFE4E7EC),
                              ),
                          ],
                        );
                      })
                    else
                      // Empty state
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Icon(Icons.credit_card_off_rounded,
                                size: 28,
                                color: widget.sub.withValues(alpha: 0.4)),
                            const SizedBox(height: 6),
                            Text(widget.l10n.paymentNoSavedCards,
                                style:
                                    TextStyle(fontSize: 12, color: widget.sub)),
                          ],
                        ),
                      ),

                    // Add card button at bottom
                    Divider(
                      height: 1,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFE4E7EC),
                    ),
                    GestureDetector(
                      onTap: widget.onAddCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.colorMain.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_rounded,
                                  size: 16, color: AppColors.colorMain),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.l10n.addNewCard,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.colorMain,
                              ),
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
        ),
      ],
    );
  }
}

class _DropdownCardItem extends StatelessWidget {
  final SavedCardModel card;
  final bool isSelected;
  final bool isDark;
  final Color sub;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _DropdownCardItem({
    required this.card,
    required this.isSelected,
    required this.isDark,
    required this.sub,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? AppColors.colorMain.withValues(alpha: isDark ? 0.15 : 0.06)
            : Colors.transparent,
        child: Row(
          children: [
            // Card chip
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isSelected
                    ? AppColors.colorMain.withValues(alpha: 0.2)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFE0E3E8)),
              ),
              child: Icon(Icons.credit_card_rounded,
                  size: 16, color: isSelected ? AppColors.colorMain : sub),
            ),
            const SizedBox(width: 12),
            // Card details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.bankName ?? card.brand,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.colorMain
                          : (isDark ? Colors.white : const Color(0xFF0D1117)),
                    ),
                  ),
                  Text(
                    '••••  ••••  ••••  ${card.lastFourDigits}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: isSelected
                          ? AppColors.colorMain.withValues(alpha: 0.7)
                          : sub,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator or delete
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.colorMain,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 12, color: Colors.white),
              )
            else
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close_rounded,
                    size: 16,
                    color: isDark ? Colors.white24 : Colors.grey[350]),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Apple Pay uses the Flutter Icons.apple (built-in, no assets needed) ──
class _ApplePayContent extends StatelessWidget {
  final String payLabel;

  const _ApplePayContent({required this.payLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.apple, color: Colors.white, size: 26),
        const SizedBox(width: 6),
        Text(payLabel,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ],
    );
  }
}

class _GooglePayContent extends StatelessWidget {
  final String payLabel;

  const _GooglePayContent({required this.payLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BankAsset(
            asset: 'assets/banks/google.png',
            size: 28,
            fallback: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: const Center(
                  child: Text('G',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
            )),
        const SizedBox(width: 8),
        Text(payLabel,
            style: const TextStyle(
                color: Color(0xFF0D1117),
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ],
    );
  }
}

class _KaspiContent extends StatelessWidget {
  const _KaspiContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BankAsset(
          asset: 'assets/banks/kaspi.jpg',
          size: 28,
          fallback: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Text('K',
                style: TextStyle(
                    color: Color(0xFFE31E24),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        const Text('Kaspi',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ],
    );
  }
}

class _BankAsset extends StatelessWidget {
  final String asset;
  final double size;
  final Widget fallback;

  const _BankAsset(
      {required this.asset, required this.size, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  final double totalPrice;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _PaymentBottomBar({
    required this.totalPrice,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.payNowLabel,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFF6E7A8A))),
              Text('${totalPrice.toInt()} ₸',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0D1117))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorMain,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.confirmPayment,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final int? maxLength;
  final bool isDark;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0D1117)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon,
            size: 20, color: AppColors.colorMain.withValues(alpha: 0.7)),
        filled: true,
        fillColor: bg,
        counterText: '',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.colorMain, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// selectedIndexProvider imported from main_scaffold for tab switch after booking
