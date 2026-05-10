import type { OwnerBooking } from '@/types/booking';

export const MOCK_DASHBOARD_STATS = {
  bookingsToday: 28,
  bookingsTodayDelta: 0.12, // +12% vs yesterday
  revenueToday: 418_500,
  revenueTodayDelta: 0.08,
  occupancyWeek: 0.74, // 74% average over week
  occupancyWeekDelta: 0.05,
  activeFacilities: 3,
  currency: 'KZT',
} as const;

export const MOCK_REVENUE_TREND: Array<{
  label: string;
  revenue: number;
  bookings: number;
}> = [
  { label: 'Mon', revenue: 310000, bookings: 22 },
  { label: 'Tue', revenue: 342000, bookings: 24 },
  { label: 'Wed', revenue: 298000, bookings: 20 },
  { label: 'Thu', revenue: 386000, bookings: 26 },
  { label: 'Fri', revenue: 512000, bookings: 34 },
  { label: 'Sat', revenue: 598000, bookings: 39 },
  { label: 'Sun', revenue: 418500, bookings: 28 },
];

export const MOCK_OCCUPANCY_HEATMAP: Array<{
  day: string;
  morning: number;
  noon: number;
  afternoon: number;
  evening: number;
  night: number;
}> = [
  { day: 'Mon', morning: 0.24, noon: 0.45, afternoon: 0.62, evening: 0.86, night: 0.54 },
  { day: 'Tue', morning: 0.26, noon: 0.48, afternoon: 0.66, evening: 0.82, night: 0.56 },
  { day: 'Wed', morning: 0.22, noon: 0.42, afternoon: 0.60, evening: 0.80, night: 0.52 },
  { day: 'Thu', morning: 0.28, noon: 0.50, afternoon: 0.70, evening: 0.88, night: 0.58 },
  { day: 'Fri', morning: 0.32, noon: 0.56, afternoon: 0.78, evening: 0.94, night: 0.62 },
  { day: 'Sat', morning: 0.38, noon: 0.66, afternoon: 0.86, evening: 0.96, night: 0.70 },
  { day: 'Sun', morning: 0.30, noon: 0.58, afternoon: 0.74, evening: 0.90, night: 0.64 },
];

export const MOCK_INCOMING_BOOKINGS: OwnerBooking[] = [
  {
    id: 'b-1',
    facility_id: 'v-almaty-arena',
    facility_name: 'Almaty Arena',
    resource_name: 'Field A — Main Pitch',
    customer_name: 'Sanzhar Team',
    start_at: '2026-05-01T13:00:00Z',
    end_at: '2026-05-01T15:00:00Z',
    attendees: 10,
    price: 48000,
    currency: 'KZT',
    status: 'pending',
  },
  {
    id: 'b-2',
    facility_id: 'v-skyline-court',
    facility_name: 'Skyline Court Center',
    resource_name: 'Court A',
    customer_name: 'Aigerim K.',
    start_at: '2026-05-02T03:00:00Z',
    end_at: '2026-05-02T04:00:00Z',
    attendees: 4,
    price: 8000,
    currency: 'KZT',
    status: 'pending',
  },
  {
    id: 'b-3',
    facility_id: 'v-tennis-park',
    facility_name: 'Tennis Park Esentai',
    resource_name: 'Court 1 — Indoor',
    customer_name: 'Baurzhan N.',
    start_at: '2026-05-03T15:00:00Z',
    end_at: '2026-05-03T16:00:00Z',
    attendees: 2,
    price: 9500,
    currency: 'KZT',
    status: 'confirmed',
  },
  {
    id: 'b-4',
    facility_id: 'v-almaty-arena',
    facility_name: 'Almaty Arena',
    resource_name: 'Indoor Court 1',
    customer_name: 'Corporate League',
    start_at: '2026-05-04T14:00:00Z',
    end_at: '2026-05-04T17:00:00Z',
    attendees: 12,
    price: 27000,
    currency: 'KZT',
    status: 'confirmed',
  },
];
