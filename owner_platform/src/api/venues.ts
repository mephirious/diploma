import { api } from './client';

export interface VenueListParams {
  owner_id?: string;
  status?: string;
  search?: string;
  city?: string;
  country?: string;
  sport?: string;
  page?: number;
  page_size?: number;
}

export interface VenueCreatePayload {
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
  contacts?: Array<{ description: string; phone?: string; email?: string; link?: string }>;
  location?: { lat: number; lng: number };
}

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

export type ScheduleCreatePayload = Partial<{
  venue_id: string;
  resource_id: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  timezone: string;
  effective_from: string;
  effective_to: string;
  status: string;
}>;

export type PricingCreatePayload = Partial<{
  venue_id: string;
  resource_id: string;
  price: number;
  currency: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  effective_from: string;
  effective_to: string;
  priority: number;
  status: string;
}>;

export type BlackoutCreatePayload = Partial<{
  venue_id: string;
  resource_id: string;
  start_at: string;
  end_at: string;
  reason: string;
  status: string;
}>;

function buildListParams(params: VenueListParams) {
  const p: Record<string, unknown> = {};
  if (params.owner_id) p['owner_id'] = params.owner_id;
  if (params.status) p['status'] = params.status;
  if (params.search) p['search'] = params.search;
  if (params.city) p['city'] = params.city;
  if (params.country) p['country'] = params.country;
  if (params.sport) p['sport'] = params.sport;
  p['list_params.page'] = params.page ?? 1;
  p['list_params.page_size'] = params.page_size ?? 50;
  return p;
}

export const venueApi = {
  list: (params: VenueListParams = {}) =>
    api.get('/venue/v1/venues', { params: buildListParams(params) }).then((r) => r.data),

  get: (id: string) => api.get(`/venue/v1/venues/${id}`).then((r) => r.data),

  create: (data: VenueCreatePayload) =>
    api.post('/venue/v1/venues', data).then((r) => r.data),

  update: (id: string, data: Partial<VenueCreatePayload>) =>
    api.put(`/venue/v1/venues/${id}`, data).then((r) => r.data),

  delete: (id: string) => api.delete(`/venue/v1/venues/${id}`),

  resources: {
    list: (venueId: string) =>
      api
        .get(`/venue/v1/venues/${venueId}/resources`, {
          params: { 'list_params.page_size': 100 },
        })
        .then((r) => r.data),
    create: (venueId: string, data: ResourceCreatePayload) =>
      api.post(`/venue/v1/venues/${venueId}/resources`, { ...data, venue_id: venueId }).then((r) => r.data),
    get: (id: string) => api.get(`/venue/v1/resources/${id}`).then((r) => r.data),
    update: (id: string, data: Partial<ResourceCreatePayload>) =>
      api.put(`/venue/v1/resources/${id}`, data).then((r) => r.data),
    delete: (id: string) => api.delete(`/venue/v1/resources/${id}`),
  },

  schedules: {
    list: (venueId: string) =>
      api
        .get(`/venue/v1/venues/${venueId}/schedules`, {
          params: { 'list_params.page_size': 100 },
        })
        .then((r) => r.data),
    result: (venueId: string) =>
      api.get(`/venue/v1/venues/${venueId}/schedule-result`).then((r) => r.data),
    create: (venueId: string, data: ScheduleCreatePayload) =>
      api.post(`/venue/v1/venues/${venueId}/schedules`, { ...data, venue_id: venueId }).then((r) => r.data),
    update: (id: string, data: Partial<ScheduleCreatePayload>) =>
      api.put(`/venue/v1/schedules/${id}`, data).then((r) => r.data),
    delete: (id: string) => api.delete(`/venue/v1/schedules/${id}`),
  },

  pricing: {
    list: (venueId: string) =>
      api
        .get(`/venue/v1/venues/${venueId}/pricing`, {
          params: { 'list_params.page_size': 100 },
        })
        .then((r) => r.data),
    create: (venueId: string, data: PricingCreatePayload) =>
      api.post(`/venue/v1/venues/${venueId}/pricing`, { ...data, venue_id: venueId }).then((r) => r.data),
    update: (id: string, data: Partial<PricingCreatePayload>) =>
      api.put(`/venue/v1/pricing/${id}`, data).then((r) => r.data),
    delete: (id: string) => api.delete(`/venue/v1/pricing/${id}`),
  },

  blackouts: {
    list: (venueId: string) =>
      api
        .get(`/venue/v1/venues/${venueId}/blackouts`, {
          params: { 'list_params.page_size': 100 },
        })
        .then((r) => r.data),
    create: (venueId: string, data: BlackoutCreatePayload) =>
      api.post(`/venue/v1/venues/${venueId}/blackouts`, { ...data, venue_id: venueId }).then((r) => r.data),
    update: (id: string, data: Partial<BlackoutCreatePayload>) =>
      api.put(`/venue/v1/blackouts/${id}`, data).then((r) => r.data),
    delete: (id: string) => api.delete(`/venue/v1/blackouts/${id}`),
  },
};
