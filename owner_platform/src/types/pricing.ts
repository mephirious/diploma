/**
 * Mirrors `PricingRuleModel` (backend `venuePricingRuleMain`).
 *
 * Notes:
 * - `price` is returned as a string (int64) by the backend, same as the mobile app handles it.
 * - `day_of_week` follows API convention: 0 = Sunday, 1 = Monday … 6 = Saturday.
 * - A pricing rule may apply to a single resource (`resource_id`) or the whole venue (null).
 */
export type PricingRule = {
  id: string;
  venue_id: string;
  resource_id: string | null;
  /** int64 as string. */
  price: string;
  /** ISO-4217. Defaults to KZT. */
  currency: string;
  /** 0 = Sunday … 6 = Saturday, or null for "any day". */
  day_of_week: number | null;
  /** HH:mm:ss in venue-local time. */
  start_time: string | null;
  end_time: string | null;
  sport: string | null;
  effective_from: string | null;
  effective_to: string | null;
  priority: number;
  status: 'active' | 'inactive';
  created_at?: string;
  updated_at?: string;
};
