import { api } from './client';
import type { Promo, PromoCreatePayload, PromoListResponse, PromoUpdatePayload } from '@/types/promo';

export const promoApi = {
  /** List all promos for a venue, optionally filtered by resource_id */
  listByVenue: (
    venueId: string,
    params: { resource_id?: string; status?: string; page_size?: number } = {},
  ): Promise<PromoListResponse> =>
    api
      .get(`/venue/v1/venues/${venueId}/promos`, {
        params: {
          'list_params.page_size': params.page_size ?? 100,
          ...(params.resource_id ? { resource_id: params.resource_id } : {}),
          ...(params.status ? { status: params.status } : {}),
        },
      })
      .then((r) => r.data),

  /** Get a single promo by ID */
  get: (id: string): Promise<Promo> =>
    api.get(`/venue/v1/promos/${id}`).then((r) => r.data),

  /** Create a new promo for a venue */
  create: (venueId: string, data: PromoCreatePayload): Promise<Promo> =>
    api.post(`/venue/v1/venues/${venueId}/promos`, data).then((r) => r.data),

  /** Update an existing promo */
  update: (id: string, data: PromoUpdatePayload): Promise<Promo> =>
    api.put(`/venue/v1/promos/${id}`, data).then((r) => r.data),

  /** Delete a promo */
  delete: (id: string): Promise<void> =>
    api.delete(`/venue/v1/promos/${id}`).then(() => undefined),
};
