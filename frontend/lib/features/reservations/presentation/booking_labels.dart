import '../../../../l10n/app_localizations.dart';

String localizedBookingStatus(AppLocalizations l10n, String raw) {
  switch (raw.toLowerCase().trim()) {
    case 'created':
      return l10n.bookingStatusCreated;
    case 'confirmed':
      return l10n.confirmed;
    case 'completed':
      return l10n.completed;
    case 'cancelled':
      return l10n.cancelled;
    case 'pending':
      return l10n.bookingStatusPending;
    case 'hold':
      return l10n.bookingStatusHold;
    case 'active':
      return l10n.bookingStatusActive;
    default:
      return _humanizeCode(raw);
  }
}

String localizedCancellationReason(AppLocalizations l10n, String raw) {
  final normalized = raw.trim().toLowerCase().replaceAll(' ', '_');
  switch (normalized) {
    case 'payment_timeout':
      return l10n.cancelReasonPaymentTimeout;
    case 'user_cancelled':
    case 'cancelled_by_user':
      return l10n.cancelReasonUserCancelled;
    case 'expired':
    case 'hold_expired':
      return l10n.cancelReasonHoldExpired;
    case 'admin_cancelled':
    case 'cancelled_by_admin':
      return l10n.cancelReasonAdminCancelled;
    case 'refund':
    case 'refunded':
      return l10n.cancelReasonRefunded;
    case 'minimum_not_met':
      return l10n.cancelReasonMinimumNotMet;
    case 'owner_cancelled':
      return l10n.cancelReasonOwnerCancelled;
    case 'session_expired':
      return l10n.cancelReasonSessionExpired;
    case 'hold_creation_failed':
      return l10n.cancelReasonHoldCreationFailed;
    default:
      if (raw.trim().toLowerCase() == 'cancelled by user') {
        return l10n.cancelReasonUserCancelled;
      }
      return _humanizeCode(raw);
  }
}

String _humanizeCode(String raw) {
  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty
          ? ''
          : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',)
      .join(' ');
}

String localizedPaymentStatus(AppLocalizations l10n, String raw) {
  final s = raw.toLowerCase().replaceAll(' ', '_');
  switch (s) {
    case 'paid':
    case 'succeeded':
      return l10n.paymentStatusPaid;
    case 'pending':
      return l10n.paymentStatusPending;
    case 'hold':
      return l10n.paymentStatusHold;
    case 'failed':
      return l10n.paymentStatusFailed;
    case 'refunded':
      return l10n.paymentStatusRefunded;
    case 'completed':
      return l10n.completed;
    default:
      return raw.replaceAll('_', ' ').replaceFirstMapped(
            RegExp(r'^[a-z]'),
            (m) => m.group(0)!.toUpperCase(),
          );
  }
}
