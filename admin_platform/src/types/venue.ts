/**
 * Mirrors the mobile frontend's `VenueModel.fromApiJson` shape so that
 * wiring a real backend later is a direct field-for-field mapping.
 */
export type VenueContact = {
  /** Maps to API `description`. */
  description: string;
  phone?: string | null;
  email?: string | null;
  link?: string | null;
};

export type VenueLocation = {
  lat: number;
  lng: number;
};

/**
 * Matches the API schema used by `/venue/v1/venues` responses.
 * Fields stay snake_case to match the Go backend's JSON.
 */
export type Venue = {
  id: string;
  name: string;
  description: string;
  sports: string[];
  address_line1: string;
  address_line2?: string;
  city: string;
  region?: string;
  country: string;
  postal_code?: string;
  location: VenueLocation | null;
  images: string[];
  contacts: VenueContact[];
  timezone?: string;
  /** ISO8601 strings (the API uses these). */
  created_at?: string;
  updated_at?: string;
  /** Owner-only metadata surfaced by the web UI. */
  status: 'active' | 'draft' | 'suspended';
  owner_id?: string | null;
  /** Embedded resources (mock only; real API fetches them separately). */
  resources?: Resource[];
};

export type Resource = {
  id: string;
  venue_id: string;
  name: string;
  description?: string | null;
  type: string;
  sport: string;
  capacity: number;
  status: string;
  surface?: string | null;
  images?: string[];
  created_at?: string;
  updated_at?: string;
};

export { VENUE_SPORT_KEYS as SPORT_KEYS, type VenueSportKey as SportKey } from '@/lib/sports';

export const AMENITY_KEYS = [
  'parking',
  'showers',
  'changingRooms',
  'cafeteria',
  'wifi',
  'equipment',
] as const;

export type AmenityKey = (typeof AMENITY_KEYS)[number];
