import { api } from './client';
import type { VenueContact } from '@/types/venue';

export interface VenueCreatePayload {
  venue_request_id?: string;
  name: string;
  description?: string;
  status?: string;
  address_line1?: string;
  address_line2?: string;
  city?: string;
  region?: string;
  country?: string;
  postal_code?: string;
  sports?: string[];
  images?: string[];
  contacts?: VenueContact[];
  location?: { lat: number; lng: number };
}

export type VenueContactPayload = {
  description: string;
  phone?: string;
  email?: string;
  link?: string;
};

export type ResourceCreatePayload = Partial<{
  venue_id: string;
  name: string;
  description: string;
  type: string;
  sport: string;
  capacity: number;
  status: string;
  surface: string;
  images: string[];
}>;

export type AdminVenue = {
  id: string;
  name: string;
  status: string;
  city: string;
  country: string;
  owner_id: string | null;
  owner?: {
    id: string;
    username: string;
    first_name: string;
    last_name: string;
    email: string;
  } | null;
  created_at: string;
  sports: string[];
};

export type ListVenuesResponse = {
  venues: AdminVenue[];
  total: number;
  page: number;
  page_size: number;
};

export const adminVenueApi = {
  listVenues: (params: { page?: number; page_size?: number; status?: string; search?: string; owner_id?: string }) =>
    api.get<ListVenuesResponse>('/venue/v1/admin/venues', { params }).then((r) => r.data),

  create: (data: VenueCreatePayload & { venue_request_id: string }) =>
    api.post('/venue/v1/admin/venues', data).then((r) => r.data),

  get: (id: string) => api.get(`/venue/v1/admin/venues/${id}`).then((r) => r.data),

  update: (id: string, data: Partial<VenueCreatePayload>) =>
    api.put(`/venue/v1/admin/venues/${id}`, data).then((r) => r.data),

  delete: (id: string) => api.delete(`/venue/v1/admin/venues/${id}`),

  contacts: {
    create: (venueId: string, contact: VenueContactPayload) =>
      api.post(`/venue/v1/admin/venues/${venueId}/contacts`, contact).then((r) => r.data),
    update: (venueId: string, index: number, contact: VenueContactPayload) =>
      api.put(`/venue/v1/admin/venues/${venueId}/contacts/${index}`, contact).then((r) => r.data),
    delete: (venueId: string, index: number) =>
      api.delete(`/venue/v1/admin/venues/${venueId}/contacts/${index}`).then((r) => r.data),
  },

  resources: {
    list: (venueId: string) =>
      api.get(`/venue/v1/admin/venues/${venueId}/resources`).then((r) => r.data),
    create: (venueId: string, data: ResourceCreatePayload) =>
      api.post(`/venue/v1/admin/venues/${venueId}/resources`, { ...data, venue_id: venueId }).then((r) => r.data),
  },

  schedules: {
    result: (venueId: string) =>
      api.get(`/venue/v1/admin/venues/${venueId}/schedule-result`).then((r) => r.data),
  },

  venueStats: () =>
    api.get<{ total_active_venues: number }>('/venue/v1/admin/stats/venues').then((r) => r.data),
};

export const venueApi = adminVenueApi;
