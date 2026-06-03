import 'package:flutter/material.dart';
import '../../../../core/sports/sport_l10n.dart' as sports_l10n;
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/session_model_simple.dart';
import '../session_price_text.dart';
import 'session_venue_info_block.dart';

class SessionCard extends StatelessWidget {
  final SessionModelSimple session;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final bool actionLoading;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onJoin,
    this.actionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sportKey = session.sportType;
    final sportColor = sports_l10n.sportColor(sportKey);
    final sportName = sports_l10n.sportLabel(l10n, sportKey);
    final showResourceSubtitle = session.resourceName.trim().isNotEmpty &&
        session.resourceName.trim() != session.displayTitle;

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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2.2,
                  child: session.coverImage.isNotEmpty
                      ? Image.network(
                          session.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _heroPlaceholder(sportColor, sportKey),
                        )
                      : _heroPlaceholder(sportColor, sportKey),
                ),
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
                        Icon(sports_l10n.sportIcon(sportKey),
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          sportName,
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
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showResourceSubtitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          session.resourceName.trim(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
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
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sessionPriceLabel(l10n, session),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.colorMain,
                              ),
                            ),
                            if (session.pricingModel == 'fixed_split')
                              Text(
                                l10n.finalPriceLocksShort,
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed:
                              session.canJoin && !actionLoading ? onJoin : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: session.isJoined
                                ? AppColors.colorSuccess
                                : AppColors.colorMain,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                isDark ? Colors.white12 : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: actionLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  session.isJoined
                                      ? l10n.joinedLabel
                                      : (session.isFull
                                          ? l10n.sessionFull
                                          : l10n.joinSession),
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
            if (session.hasVenueInfo)
              SessionVenueInfoBlock(
                venueName: session.venueName,
                venueAddress: session.venueAddress,
                distance: session.distance,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _heroPlaceholder(Color sportColor, String sportKey) {
    return ColoredBox(
      color: sportColor.withOpacity(0.2),
      child: Center(
        child: Icon(sports_l10n.sportIcon(sportKey), size: 48, color: sportColor),
      ),
    );
  }
}
