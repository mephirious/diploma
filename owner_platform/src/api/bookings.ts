import { api } from './client';
import type { ApiBooking } from '@/types/booking';

export interface BookingListParams {
  venue_id?: string;
  venue_ids?: string[];
  resource_id?: string;
  status?: string;
  payment_status?: string;
  from?: string;
  to?: string;
  include_cancelled?: boolean;
  page?: number;
  page_size?: number;
  /** Server sort field, e.g. `start_at` or `-end_at`. */
  sort?: string;
  with_total_count?: boolean;
}

export interface BookingStatsParams {
  venue_ids: string[];
  from?: string;
  to?: string;
}

export interface BookingListResponse {
  results: ApiBooking[];
  pagination_info?: {
    page?: string | number;
    page_size?: string | number;
    total_count?: string | number;
  };
}

function buildListParams(params: BookingListParams): Record<string, unknown> {
  const p: Record<string, unknown> = {};
  if (params.venue_id) p['venue_id'] = params.venue_id;
  if (params.resource_id) p['resource_id'] = params.resource_id;
  if (params.status) p['status'] = params.status;
  if (params.payment_status) p['payment_status'] = params.payment_status;
  if (params.from) p['from'] = params.from;
  if (params.to) p['to'] = params.to;
  if (params.include_cancelled !== undefined) {
    p['include_cancelled'] = params.include_cancelled;
  }
  p['list_params.page'] = params.page ?? 0;
  p['list_params.page_size'] = params.page_size ?? 50;
  if (params.sort) {
    p['list_params.sort'] = params.sort;
  }
  if (params.with_total_count) {
    p['list_params.with_total_count'] = true;
  }

  const venueIds = (params.venue_ids ?? []).map((id) => id.trim()).filter(Boolean);
  if (venueIds.length > 0) {
    p['venue_ids'] = venueIds;
  }

  return p;
}

export const bookingApi = {
  list: (params: BookingListParams = {}) =>
    api
      .get<BookingListResponse>('/booking/v1/bookings', {
        params: buildListParams(params),
        paramsSerializer: { indexes: null },
      })
      .then((r) => r.data),

  get: (id: string) => api.get<ApiBooking>(`/booking/v1/bookings/${id}`).then((r) => r.data),

  confirm: (id: string) =>
    api.post<ApiBooking>(`/booking/v1/bookings/${id}/confirm`).then((r) => r.data),

  cancel: (id: string, reason?: string) =>
    api
      .post<ApiBooking>(`/booking/v1/bookings/${id}/cancel`, { reason })
      .then((r) => r.data),

  stats: (params: BookingStatsParams) =>
    api
      .get('/booking/v1/bookings/stats', {
        params: {
          venue_ids: params.venue_ids.join(','),
          from: params.from,
          to: params.to,
        },
      })
      .then((r) => r.data),
};
