import type { VenueContact, Venue } from '@/types/venue';

export function formatPrice(amount: number, currency = 'KZT'): string {
  if (currency === 'KZT') {
    return `${new Intl.NumberFormat('ru-RU').format(amount)} ₸`;
  }
  return new Intl.NumberFormat(undefined, {
    style: 'currency',
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatPriceString(raw: string, currency = 'KZT'): string {
  const n = Number.parseInt(raw, 10);
  if (Number.isNaN(n)) return '—';
  return formatPrice(n, currency);
}

/** "HH:mm:ss" → "HH:mm". Returns the input if already short or invalid. */
export function shortTime(t: string | null | undefined): string {
  if (!t) return '';
  const parts = t.split(':');
  if (parts.length < 2) return t;
  return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
}

export function timeToHour(t: string | null | undefined): number {
  if (!t) return 0;
  return Number.parseInt(t.split(':')[0] ?? '0', 10) || 0;
}

export function buildAddress(v: Pick<Venue, 'address_line1' | 'address_line2' | 'city' | 'country'>): string {
  return [v.address_line1, v.address_line2, v.city, v.country]
    .map((p) => (p ?? '').trim())
    .filter((p) => p.length > 0)
    .join(', ');
}

export function firstContactOfKind(
  contacts: VenueContact[],
  kind: 'phone' | 'email' | 'link',
): string | null {
  const c = contacts.find((x) => !!x[kind]);
  return c ? (c[kind] ?? null) : null;
}

/** 0 = Sunday, 1 = Monday, …, 6 = Saturday (API convention). */
export const WEEKDAY_KEYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] as const;
export type WeekdayKey = (typeof WEEKDAY_KEYS)[number];

export function apiDayOfWeek(date: Date): number {
  return date.getDay();
}

/** Format an ISO instant in an IANA timezone (falls back if invalid TZ). */
export function formatInTimezone(
  iso: string | null | undefined,
  timezone: string | null | undefined,
  locale: string,
  options: Intl.DateTimeFormatOptions,
): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  const tz = timezone?.trim() || 'UTC';
  try {
    return new Intl.DateTimeFormat(locale, { ...options, timeZone: tz }).format(d);
  } catch {
    return new Intl.DateTimeFormat(locale, options).format(d);
  }
}

/** "YYYY-MM-DD" (UTC calendar day) → short weekday in locale. */
export function formatShortDayFromIsoDate(isoDay: string, locale: string): string {
  const parts = isoDay.split('-').map((x) => Number.parseInt(x, 10));
  const y = parts[0];
  const m = parts[1];
  const d = parts[2];
  if (!y || !m || !d) return isoDay;
  return new Intl.DateTimeFormat(locale, { weekday: 'short' }).format(new Date(Date.UTC(y, m - 1, d)));
}

