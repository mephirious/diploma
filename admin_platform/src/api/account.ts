import { api } from './client';

export type AdminOwner = {
  id: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  is_active: boolean;
  created_at: string;
};

export type AdminOwnerDetail = AdminOwner & {
  roles: string[];
  updated_at: string;
};

export type ListOwnersResponse = {
  owners: AdminOwner[];
  total: number;
  page: number;
  page_size: number;
};

export type VenueRequestStatus = 'created' | 'awaiting' | 'reviewing' | 'approved' | 'cancelled';

export type AdminVenueRequest = {
  id: string;
  user_id: string;
  phone: string;
  full_name: string;
  facility_name: string;
  comment?: string | null;
  doc_path?: string | null;
  status: VenueRequestStatus;
  created_at: string;
  updated_at: string;
  user: {
    id: string;
    username: string;
    email: string;
    first_name: string;
    last_name: string;
  };
};

export type ListVenueRequestsResponse = {
  requests: AdminVenueRequest[];
  total: number;
  page: number;
  page_size: number;
};

export type VenueRequestDocument = {
  blob: Blob;
  contentType: string;
};

export const adminApi = {
  listOwners: (params: { page?: number; page_size?: number; active?: boolean; search?: string }) =>
    api.get<ListOwnersResponse>('/account/v1/admin/owners', { params }).then((r) => r.data),

  ownerDetail: (id: string) =>
    api.get<AdminOwnerDetail>(`/account/v1/admin/owners/${id}`).then((r) => r.data),

  updateOwnerStatus: (id: string, is_active: boolean) =>
    api
      .patch<AdminOwnerDetail>(`/account/v1/admin/owners/${id}/status`, { is_active })
      .then((r) => r.data),

  listVenueRequests: (params: { page?: number; page_size?: number; status?: string; search?: string }) =>
    api
      .get<ListVenueRequestsResponse>('/account/v1/admin/venue-requests', { params })
      .then((r) => r.data),

  venueRequestDocument: (id: string) =>
    api
      .get<Blob>(`/account/v1/admin/venue-requests/${id}/document`, { responseType: 'blob' })
      .then((r) => ({
        blob: r.data,
        contentType: String(r.headers['content-type'] ?? r.data.type ?? ''),
      })),

  updateVenueRequestStatus: (id: string, status: VenueRequestStatus) =>
    api
      .patch<AdminVenueRequest>(`/account/v1/admin/venue-requests/${id}/status`, { status })
      .then((r) => r.data),

  stats: () =>
    api.get<{ total_active_owners: number }>('/account/v1/admin/stats').then((r) => r.data),
};
