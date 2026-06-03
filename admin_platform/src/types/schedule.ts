import type { PricingRule } from './pricing';
import type { Resource } from './resource';

/** Mirrors `ResourceScheduleEntryModel` (weekly recurring schedule). */
export type ResourceScheduleEntry = {
  id: string;
  resource_id: string;
  /** 0 = Sunday … 6 = Saturday. */
  day_of_week: number;
  /** HH:mm:ss local to the venue. */
  start_time: string;
  end_time: string;
  timezone: string | null;
  status: 'active' | 'inactive';
};

/** Mirrors `BlackoutModel`. Maintenance / unavailable window in UTC. */
export type Blackout = {
  id: string;
  resource_id: string;
  /** UTC ISO8601 strings. */
  start_at: string;
  end_at: string;
  status: 'active' | 'inactive';
  reason?: string;
};

/**
 * Mirrors `ScheduleResultGroup` from `/venues/{id}/schedule-result`.
 * One entry per resource with its schedule/pricing/blackouts.
 */
export type ScheduleResultGroup = {
  resource_id: string;
  resource: Resource;
  schedules: ResourceScheduleEntry[];
  pricing: PricingRule[];
  blackouts: Blackout[];
};

export type VenueScheduleResult = {
  venue_id: string;
  groups: ScheduleResultGroup[];
};
