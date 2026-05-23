import type { TFunction } from 'i18next';

/** Aligns with mobile `booking_labels.dart` — maps API codes to owner UI strings. */
export function localizedBookingStatus(t: TFunction, raw: string): string {
  const key = raw.toLowerCase().trim();
  const map: Record<string, string> = {
    created: 'booking.status.created',
    confirmed: 'booking.status.confirmed',
    completed: 'booking.status.completed',
    cancelled: 'booking.status.cancelled',
    pending: 'booking.status.pending',
    hold: 'booking.status.hold',
    active: 'booking.status.active',
  };
  const trKey = map[key];
  return trKey ? t(trKey) : humanizeCode(raw);
}

export function localizedPaymentStatus(t: TFunction, raw: string): string {
  const s = raw.toLowerCase().replaceAll(' ', '_');
  const map: Record<string, string> = {
    paid: 'booking.payment.paid',
    succeeded: 'booking.payment.paid',
    pending: 'booking.payment.pending',
    hold: 'booking.payment.hold',
    failed: 'booking.payment.failed',
    refunded: 'booking.payment.refunded',
    completed: 'booking.payment.completed',
  };
  const trKey = map[s];
  return trKey ? t(trKey) : humanizeCode(raw);
}

export function localizedCancelReason(t: TFunction, raw: string): string {
  const normalized = raw.trim().toLowerCase().replaceAll(' ', '_');
  const map: Record<string, string> = {
    payment_timeout: 'booking.cancelReason.paymentTimeout',
    user_cancelled: 'booking.cancelReason.userCancelled',
    cancelled_by_user: 'booking.cancelReason.userCancelled',
    expired: 'booking.cancelReason.expired',
    hold_expired: 'booking.cancelReason.holdExpired',
    admin_cancelled: 'booking.cancelReason.adminCancelled',
    cancelled_by_admin: 'booking.cancelReason.adminCancelled',
    refund: 'booking.cancelReason.refund',
    refunded: 'booking.cancelReason.refund',
  };
  const trKey = map[normalized];
  if (trKey) return t(trKey);
  if (normalized === 'cancelled by user') return t('booking.cancelReason.userCancelled');
  return humanizeCode(raw);
}

function humanizeCode(raw: string): string {
  return raw
    .replaceAll('_', ' ')
    .split(' ')
    .filter(Boolean)
    .map((w) => (w.length ? w[0].toUpperCase() + w.slice(1).toLowerCase() : ''))
    .join(' ');
}
