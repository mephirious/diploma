import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Compact venue context (name, address) for session cards and detail.
class SessionVenueInfoBlock extends StatelessWidget {
  final String venueName;
  final String venueAddress;
  final double distance;
  final EdgeInsetsGeometry padding;

  const SessionVenueInfoBlock({
    super.key,
    required this.venueName,
    required this.venueAddress,
    this.distance = 0,
    this.padding = const EdgeInsets.all(12),
  });

  bool get _hasContent =>
      venueName.trim().isNotEmpty || venueAddress.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!;
    final fillColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50];

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.location,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (venueName.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                venueName.trim(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
              ),
            ],
            if (venueAddress.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venueAddress.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (distance > 0)
                    Text(
                      l10n.kmAway(distance.toStringAsFixed(1)),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorMain,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
