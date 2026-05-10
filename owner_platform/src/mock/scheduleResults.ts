import type { Resource } from '@/types/resource';
import type {
  Blackout,
  ResourceScheduleEntry,
  ScheduleResultGroup,
  VenueScheduleResult,
} from '@/types/schedule';
import type { PricingRule } from '@/types/pricing';

/**
 * Builder helpers — keep data shape identical to the mobile-consumed API so
 * when the real backend arrives, the transport layer is the only thing that
 * needs swapping.
 */

function makeWeekly(
  resourceId: string,
  days: Array<{ dow: number; start: string; end: string }>,
  timezone = 'Asia/Almaty',
): ResourceScheduleEntry[] {
  return days.map((d, idx) => ({
    id: `${resourceId}-sch-${idx}`,
    resource_id: resourceId,
    day_of_week: d.dow,
    start_time: d.start,
    end_time: d.end,
    timezone,
    status: 'active',
  }));
}

function makePricing(
  venueId: string,
  resourceId: string,
  rules: Array<Omit<PricingRule, 'id' | 'venue_id' | 'resource_id' | 'status'>>,
): PricingRule[] {
  return rules.map((r, idx) => ({
    id: `${resourceId}-pr-${idx}`,
    venue_id: venueId,
    resource_id: resourceId,
    status: 'active',
    ...r,
  }));
}

function makeBlackouts(
  resourceId: string,
  windows: Array<{ start: string; end: string; reason?: string }>,
): Blackout[] {
  return windows.map((w, idx) => ({
    id: `${resourceId}-bo-${idx}`,
    resource_id: resourceId,
    start_at: w.start,
    end_at: w.end,
    status: 'active',
    reason: w.reason,
  }));
}

// ── Almaty Arena ────────────────────────────────────────────────────────
const arenaResources: Resource[] = [
  {
    id: 'r-arena-field-a',
    venue_id: 'v-almaty-arena',
    name: 'Field A — Main Pitch',
    description: '11v11 natural grass field with stadium lighting.',
    type: 'field',
    sport: 'football',
    capacity: 22,
    status: 'active',
    surface: 'Natural grass',
    images: [
      'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=1200',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=1200',
    ],
  },
  {
    id: 'r-arena-field-b',
    venue_id: 'v-almaty-arena',
    name: 'Field B — Training Pitch',
    description: '7v7 artificial turf pitch, great for small-side games.',
    type: 'field',
    sport: 'football',
    capacity: 14,
    status: 'active',
    surface: 'Artificial turf',
    images: [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=1200',
    ],
  },
  {
    id: 'r-arena-court-1',
    venue_id: 'v-almaty-arena',
    name: 'Indoor Court 1',
    description: 'Multi-purpose indoor court — basketball & volleyball.',
    type: 'court',
    sport: 'basketball',
    capacity: 12,
    status: 'active',
    surface: 'Hardwood',
    images: [
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200',
    ],
  },
];

const arenaGroups: ScheduleResultGroup[] = [
  {
    resource_id: arenaResources[0].id,
    resource: arenaResources[0],
    schedules: makeWeekly(arenaResources[0].id, [
      { dow: 1, start: '08:00:00', end: '23:00:00' },
      { dow: 2, start: '08:00:00', end: '23:00:00' },
      { dow: 3, start: '08:00:00', end: '23:00:00' },
      { dow: 4, start: '08:00:00', end: '23:00:00' },
      { dow: 5, start: '08:00:00', end: '23:00:00' },
      { dow: 6, start: '09:00:00', end: '23:00:00' },
      { dow: 0, start: '09:00:00', end: '22:00:00' },
    ]),
    pricing: makePricing('v-almaty-arena', arenaResources[0].id, [
      {
        price: '18000',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'football',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
      {
        price: '24000',
        currency: 'KZT',
        day_of_week: 5,
        start_time: '18:00:00',
        end_time: '23:00:00',
        sport: 'football',
        effective_from: null,
        effective_to: null,
        priority: 10,
      },
      {
        price: '26000',
        currency: 'KZT',
        day_of_week: 6,
        start_time: '10:00:00',
        end_time: '22:00:00',
        sport: 'football',
        effective_from: null,
        effective_to: null,
        priority: 10,
      },
    ]),
    blackouts: makeBlackouts(arenaResources[0].id, [
      {
        start: '2026-05-06T09:00:00Z',
        end: '2026-05-06T13:00:00Z',
        reason: 'Pitch maintenance',
      },
    ]),
  },
  {
    resource_id: arenaResources[1].id,
    resource: arenaResources[1],
    schedules: makeWeekly(arenaResources[1].id, [
      { dow: 1, start: '07:00:00', end: '22:00:00' },
      { dow: 2, start: '07:00:00', end: '22:00:00' },
      { dow: 3, start: '07:00:00', end: '22:00:00' },
      { dow: 4, start: '07:00:00', end: '22:00:00' },
      { dow: 5, start: '07:00:00', end: '22:00:00' },
      { dow: 6, start: '09:00:00', end: '22:00:00' },
    ]),
    pricing: makePricing('v-almaty-arena', arenaResources[1].id, [
      {
        price: '12000',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'football',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
      {
        price: '15000',
        currency: 'KZT',
        day_of_week: null,
        start_time: '19:00:00',
        end_time: '22:00:00',
        sport: 'football',
        effective_from: null,
        effective_to: null,
        priority: 5,
      },
    ]),
    blackouts: [],
  },
  {
    resource_id: arenaResources[2].id,
    resource: arenaResources[2],
    schedules: makeWeekly(arenaResources[2].id, [
      { dow: 1, start: '09:00:00', end: '22:00:00' },
      { dow: 2, start: '09:00:00', end: '22:00:00' },
      { dow: 3, start: '09:00:00', end: '22:00:00' },
      { dow: 4, start: '09:00:00', end: '22:00:00' },
      { dow: 5, start: '09:00:00', end: '22:00:00' },
      { dow: 6, start: '10:00:00', end: '22:00:00' },
      { dow: 0, start: '10:00:00', end: '20:00:00' },
    ]),
    pricing: makePricing('v-almaty-arena', arenaResources[2].id, [
      {
        price: '9000',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'basketball',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
    ]),
    blackouts: [],
  },
];

// ── Skyline Court Center ────────────────────────────────────────────────
const skylineResources: Resource[] = [
  {
    id: 'r-skyline-court-a',
    venue_id: 'v-skyline-court',
    name: 'Court A',
    description: 'Full-size basketball court with maple flooring.',
    type: 'court',
    sport: 'basketball',
    capacity: 10,
    status: 'active',
    surface: 'Maple wood',
    images: [
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200',
    ],
  },
  {
    id: 'r-skyline-court-b',
    venue_id: 'v-skyline-court',
    name: 'Court B',
    description: 'Smaller practice court — streetball style.',
    type: 'court',
    sport: 'basketball',
    capacity: 6,
    status: 'maintenance',
    surface: 'Hardwood',
    images: [
      'https://images.unsplash.com/photo-1559692048-79a3f837883d?w=1200',
    ],
  },
];

const skylineGroups: ScheduleResultGroup[] = [
  {
    resource_id: skylineResources[0].id,
    resource: skylineResources[0],
    schedules: makeWeekly(skylineResources[0].id, [
      { dow: 1, start: '08:00:00', end: '22:00:00' },
      { dow: 2, start: '08:00:00', end: '22:00:00' },
      { dow: 3, start: '08:00:00', end: '22:00:00' },
      { dow: 4, start: '08:00:00', end: '22:00:00' },
      { dow: 5, start: '08:00:00', end: '23:00:00' },
      { dow: 6, start: '10:00:00', end: '23:00:00' },
      { dow: 0, start: '10:00:00', end: '21:00:00' },
    ]),
    pricing: makePricing('v-skyline-court', skylineResources[0].id, [
      {
        price: '8000',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'basketball',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
      {
        price: '11000',
        currency: 'KZT',
        day_of_week: 6,
        start_time: null,
        end_time: null,
        sport: 'basketball',
        effective_from: null,
        effective_to: null,
        priority: 10,
      },
    ]),
    blackouts: [],
  },
  {
    resource_id: skylineResources[1].id,
    resource: skylineResources[1],
    schedules: [],
    pricing: [],
    blackouts: makeBlackouts(skylineResources[1].id, [
      {
        start: '2026-05-01T00:00:00Z',
        end: '2026-05-10T00:00:00Z',
        reason: 'Flooring refurbishment',
      },
    ]),
  },
];

// ── Aqua Sprint Pool ────────────────────────────────────────────────────
const aquaResources: Resource[] = [
  {
    id: 'r-aqua-lane-1',
    venue_id: 'v-aqua-sprint',
    name: 'Lane 1',
    description: 'Training lane with starting blocks.',
    type: 'lane',
    sport: 'swimming',
    capacity: 1,
    status: 'active',
    surface: 'Water',
    images: [
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1200',
    ],
  },
  {
    id: 'r-aqua-lane-2',
    venue_id: 'v-aqua-sprint',
    name: 'Lane 2',
    description: 'Leisure lane.',
    type: 'lane',
    sport: 'swimming',
    capacity: 1,
    status: 'active',
    surface: 'Water',
    images: [
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1200',
    ],
  },
];

const aquaGroups: ScheduleResultGroup[] = [
  {
    resource_id: aquaResources[0].id,
    resource: aquaResources[0],
    schedules: makeWeekly(aquaResources[0].id, [
      { dow: 1, start: '06:00:00', end: '21:00:00' },
      { dow: 2, start: '06:00:00', end: '21:00:00' },
      { dow: 3, start: '06:00:00', end: '21:00:00' },
      { dow: 4, start: '06:00:00', end: '21:00:00' },
      { dow: 5, start: '06:00:00', end: '22:00:00' },
      { dow: 6, start: '08:00:00', end: '22:00:00' },
    ]),
    pricing: makePricing('v-aqua-sprint', aquaResources[0].id, [
      {
        price: '4500',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'swimming',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
    ]),
    blackouts: [],
  },
  {
    resource_id: aquaResources[1].id,
    resource: aquaResources[1],
    schedules: makeWeekly(aquaResources[1].id, [
      { dow: 1, start: '06:00:00', end: '21:00:00' },
      { dow: 2, start: '06:00:00', end: '21:00:00' },
      { dow: 3, start: '06:00:00', end: '21:00:00' },
      { dow: 4, start: '06:00:00', end: '21:00:00' },
      { dow: 5, start: '06:00:00', end: '22:00:00' },
    ]),
    pricing: makePricing('v-aqua-sprint', aquaResources[1].id, [
      {
        price: '3500',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'swimming',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
    ]),
    blackouts: [],
  },
];

// ── Tennis Park Esentai ─────────────────────────────────────────────────
const tennisResources: Resource[] = [
  {
    id: 'r-tennis-court-1',
    venue_id: 'v-tennis-park',
    name: 'Court 1 — Indoor',
    description: 'Hard court with premium lighting.',
    type: 'court',
    sport: 'tennis',
    capacity: 4,
    status: 'active',
    surface: 'Hard',
    images: [
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1200',
    ],
  },
  {
    id: 'r-tennis-court-5',
    venue_id: 'v-tennis-park',
    name: 'Court 5 — Outdoor Clay',
    description: 'Clay court, open seasonally.',
    type: 'court',
    sport: 'tennis',
    capacity: 4,
    status: 'active',
    surface: 'Clay',
    images: [
      'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=1200',
    ],
  },
];

const tennisGroups: ScheduleResultGroup[] = [
  {
    resource_id: tennisResources[0].id,
    resource: tennisResources[0],
    schedules: makeWeekly(tennisResources[0].id, [
      { dow: 1, start: '07:00:00', end: '23:00:00' },
      { dow: 2, start: '07:00:00', end: '23:00:00' },
      { dow: 3, start: '07:00:00', end: '23:00:00' },
      { dow: 4, start: '07:00:00', end: '23:00:00' },
      { dow: 5, start: '07:00:00', end: '23:00:00' },
      { dow: 6, start: '08:00:00', end: '23:00:00' },
      { dow: 0, start: '08:00:00', end: '22:00:00' },
    ]),
    pricing: makePricing('v-tennis-park', tennisResources[0].id, [
      {
        price: '7000',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'tennis',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
      {
        price: '9500',
        currency: 'KZT',
        day_of_week: null,
        start_time: '18:00:00',
        end_time: '23:00:00',
        sport: 'tennis',
        effective_from: null,
        effective_to: null,
        priority: 5,
      },
    ]),
    blackouts: [],
  },
  {
    resource_id: tennisResources[1].id,
    resource: tennisResources[1],
    schedules: makeWeekly(tennisResources[1].id, [
      { dow: 1, start: '09:00:00', end: '20:00:00' },
      { dow: 2, start: '09:00:00', end: '20:00:00' },
      { dow: 3, start: '09:00:00', end: '20:00:00' },
      { dow: 4, start: '09:00:00', end: '20:00:00' },
      { dow: 5, start: '09:00:00', end: '20:00:00' },
      { dow: 6, start: '10:00:00', end: '20:00:00' },
    ]),
    pricing: makePricing('v-tennis-park', tennisResources[1].id, [
      {
        price: '8500',
        currency: 'KZT',
        day_of_week: null,
        start_time: null,
        end_time: null,
        sport: 'tennis',
        effective_from: null,
        effective_to: null,
        priority: 0,
      },
    ]),
    blackouts: [],
  },
];

const RESULTS: Record<string, VenueScheduleResult> = {
  'v-almaty-arena': {
    venue_id: 'v-almaty-arena',
    groups: arenaGroups,
  },
  'v-skyline-court': {
    venue_id: 'v-skyline-court',
    groups: skylineGroups,
  },
  'v-aqua-sprint': {
    venue_id: 'v-aqua-sprint',
    groups: aquaGroups,
  },
  'v-tennis-park': {
    venue_id: 'v-tennis-park',
    groups: tennisGroups,
  },
};

export function getScheduleResult(venueId: string): VenueScheduleResult {
  return RESULTS[venueId] ?? { venue_id: venueId, groups: [] };
}

export function getAllResources(): Resource[] {
  return Object.values(RESULTS).flatMap((r) => r.groups.map((g) => g.resource));
}

export function getScheduleGroup(
  venueId: string,
  resourceId: string,
): ScheduleResultGroup | null {
  return (
    getScheduleResult(venueId).groups.find((g) => g.resource_id === resourceId) ??
    null
  );
}
