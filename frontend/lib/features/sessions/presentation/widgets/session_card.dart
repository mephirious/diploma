import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/session_model_simple.dart';

class SessionCard extends StatelessWidget {
  final SessionModelSimple session;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onJoin,
  });

  IconData _sportIcon(String sport) {
    switch (sport) {
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'swimming':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tabletennis':
        return Icons.sports_cricket;
      default:
        return Icons.sports;
    }
  }

  Color _sportColor(String sport) {
    switch (sport) {
      case 'football':
        return const Color(0xFF4CAF50);
      case 'basketball':
        return const Color(0xFFFF9800);
      case 'tennis':
        return const Color(0xFFFFC107);
      case 'volleyball':
        return const Color(0xFF2196F3);
      case 'swimming':
        return const Color(0xFF00BCD4);
      case 'gym':
        return const Color(0xFF9C27B0);
      case 'badminton':
        return const Color(0xFF8BC34A);
      default:
        return AppColors.colorMain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sportColor = _sportColor(session.sportType);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark
            ? BorderSide(color: Colors.white.withOpacity(0.1))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Top section with image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2.2,
                  child: Image.network(
                    session.venueImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: sportColor.withOpacity(0.2),
                      child: Icon(_sportIcon(session.sportType),
                          size: 48, color: sportColor),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sport badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sportColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_sportIcon(session.sportType),
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          session.sportType[0].toUpperCase() +
                              session.sportType.substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Live badge
                if (session.isLive)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                          const SizedBox(width: 5),
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
                  ),
                // Venue name on image
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    session.venueName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address & Distance
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.venueAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        l10n.kmAway(session.distance.toStringAsFixed(1)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Time slots
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: session.timeSlots.map((slot) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.colorMain.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.colorMain.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.colorMain,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Bottom row: Players, Price, Join button
                  Row(
                    children: [
                      // Player avatars stack
                      SizedBox(
                        width: 56,
                        height: 24,
                        child: Stack(
                          children: List.generate(
                            session.currentPlayers.clamp(0, 3),
                            (i) => Positioned(
                              left: i * 16.0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: sportColor.withOpacity(0.7 - i * 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[900]!
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.playersCount(
                            session.currentPlayers, session.maxPlayers),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        '${session.pricePerPlayer.toInt()} ₸',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.colorMain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Join button
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: session.isFull ? null : onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorMain,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.joinSession,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
