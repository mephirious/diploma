import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/venue_model.dart';
import '../providers/venue_provider.dart';

class VenueCard extends ConsumerWidget {
  final VenueModel venue;
  final VoidCallback onTap;

  const VenueCard({super.key, required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Real-time favorite state from the notifier (handles optimistic updates).
    final isFav = ref.watch(favoriteIdsProvider).contains(venue.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: venue.images.isNotEmpty
                      ? Image.network(
                          venue.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.sports,
                              size: 48,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.sports,
                            size: 48,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white.withOpacity(0.92),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () =>
                          ref.read(favoriteIdsProvider.notifier).toggle(venue.id),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFav),
                            color: isFav ? Colors.redAccent : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Open now badge
                if (venue.isOpen)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.colorSuccess,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(l10n.openNow,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                // Distance badge
                if (venue.distance > 0)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(l10n.kmAway(venue.distance.toStringAsFixed(1)),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venue.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(venue.address,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
