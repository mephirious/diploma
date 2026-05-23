import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/owner_mock_data.dart';

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            PageTitleHeader(title: l10n.bookingsDashboard),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.colorMain,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white70 : Colors.grey.shade700,
                  tabs: [
                    Tab(text: l10n.incomingRequests),
                    Tab(text: l10n.upcomingSessionsTitle),
                    Tab(text: l10n.pastSessionsTitle),
                    Tab(text: l10n.cancellationsTitle),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BookingsList(items: OwnerMockData.incomingBookings),
                  _BookingsList(items: OwnerMockData.upcomingSessions),
                  _BookingsList(items: OwnerMockData.pastSessions),
                  _BookingsList(items: OwnerMockData.cancellations),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<OwnerBookingItem> items;

  const _BookingsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.noBookings,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final statusColor = switch (item.status) {
          'pending' => AppColors.colorWarning,
          'confirmed' => AppColors.colorSuccess,
          'completed' => AppColors.colorInfo,
          _ => AppColors.colorError,
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.facilityName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.customerName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: AppColors.colorMain),
                  const SizedBox(width: 6),
                  Text(item.date),
                  const SizedBox(width: 14),
                  const Icon(Icons.schedule,
                      size: 16, color: AppColors.colorMain),
                  const SizedBox(width: 6),
                  Text(item.slot),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.group_outlined,
                      size: 16, color: AppColors.colorMain),
                  const SizedBox(width: 6),
                  Text(l10n.playersCount(item.attendees, item.attendees)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
