import { api } from './client';

export interface BookingListParams {
  venue_id?: string;
  resource_id?: string;
  status?: string;
  from?: string;
  to?: string;
  page?: number;
  page_size?: number;
}

export interface BookingStatsParams {
  venue_ids: string[];
  from?: string;
  to?: string;
}

export const bookingApi = {
  list: (params: BookingListParams = {}) => {
    const p: Record<string, unknown> = {};
    if (params.venue_id) p['venue_id'] = params.venue_id;
    if (params.resource_id) p['resource_id'] = params.resource_id;
    if (params.status) p['status'] = params.status;
    if (params.from) p['from'] = params.from;
    if (params.to) p['to'] = params.to;
    p['list_params.page'] = params.page ?? 1;
    p['list_params.page_size'] = params.page_size ?? 50;
    return api.get('/booking/v1/bookings', { params: p }).then((r) => r.data);
  },

  get: (id: string) => api.get(`/booking/v1/bookings/${id}`).then((r) => r.data),

  confirm: (id: string) =>
    api.post(`/booking/v1/bookings/${id}/confirm`).then((r) => r.data),

  cancel: (id: string, reason?: string) =>
    api.post(`/booking/v1/bookings/${id}/cancel`, { reason }).then((r) => r.data),

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
