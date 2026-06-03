import 'package:intl/intl.dart';

import '../../venues/data/models/resource_model.dart';
import '../../venues/data/models/venue_model.dart';
import 'models/session_api_model.dart';
import 'models/session_model_simple.dart';

class SessionMapper {
  static SessionModelSimple toDisplay(
    SessionApiModel session, {
    VenueModel? venue,
    ResourceModel? resource,
    bool isJoined = false,
  }) {
    final startsLocal = session.startsAt.toLocal();
    final endsLocal = session.endsAt.toLocal();
    final timeFmt = DateFormat('HH:mm');

    final venueName = venue?.name ?? '';
    final venueAddress = venue?.address ?? '';
    final resourceName = resource?.displayName ?? '';
    final sessionTitle = session.name.trim().isNotEmpty
        ? session.name.trim()
        : resourceName;
    final coverImage = resource?.images.isNotEmpty == true
        ? resource!.images.first
        : '';
    final venueImage =
        venue?.images.isNotEmpty == true ? venue!.images.first : '';

    final displayPrice = _displayPriceMinor(session);
    final now = DateTime.now().toUtc();
    final isLive = session.status == 'active' ||
        (now.isAfter(session.startsAt) && now.isBefore(session.endsAt));

    return SessionModelSimple(
      id: session.id,
      sportType: session.sport,
      skillLevel: session.mode,
      sessionTitle: sessionTitle,
      resourceName: resourceName,
      venueName: venueName,
      venueAddress: venueAddress,
      venueImage: venueImage,
      coverImage: coverImage,
      hostName: venueName.isNotEmpty ? venueName : resourceName,
      hostAvatar: '',
      maxPlayers: session.maxParticipants,
      currentPlayers: session.participantCount,
      pricePerPlayer: displayPrice.toDouble(),
      timeSlots: [
        '${timeFmt.format(startsLocal)} – ${timeFmt.format(endsLocal)}',
      ],
      date: startsLocal,
      isLive: isLive,
      distance: 0,
      description: session.description?.trim().isNotEmpty == true
          ? session.description!.trim()
          : session.name,
      status: session.status,
      cancelReason: session.cancelReason,
      mode: session.mode,
      locksAt: session.locksAt,
      ownerId: session.ownerId,
      minParticipants: session.minParticipants,
      pricingModel: session.pricingModel,
      currency: session.currency,
      priceTotalMinor: session.priceTotalMinor,
      pricePerPersonMinor: session.pricePerPersonMinor,
      priceRangeMinMinor: session.priceRangeMinMinor,
      priceRangeMaxMinor: session.priceRangeMaxMinor,
      venueId: session.venueId,
      resourceId: session.resourceId,
      isJoined: isJoined,
      slotAvailable: session.slotAvailable,
    );
  }

  /// Worst-case join quote shown in the feed (matches backend join logic).
  static int _displayPriceMinor(SessionApiModel s) {
    if (s.pricingModel == 'fixed_split') {
      if (s.priceRangeMaxMinor != null) return s.priceRangeMaxMinor!;
      if (s.priceTotalMinor != null && s.minParticipants > 0) {
        return (s.priceTotalMinor! / s.minParticipants).ceil();
      }
      return s.priceTotalMinor ?? 0;
    }
    return s.pricePerPersonMinor ?? s.lockedPricePerPersonMinor ?? 0;
  }
}
