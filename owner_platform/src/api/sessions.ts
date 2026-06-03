import { api } from './client';
import type {
  OwnerSessionCreatePayload,
  PaginatedSessions,
  PaginatedTemplates,
  SessionInstance,
  SessionParticipantsOwner,
  SessionTemplate,
  TemplateCreatePayload,
  TemplateUpdatePayload,
} from '@/types/session';

export type OwnerSessionListParams = {
  resource_id?: string;
  mode?: string;
  status?: string;
  statuses?: string;
  timeframe?: 'upcoming' | 'past' | 'all';
  page?: number;
  page_size?: number;
};

export type TemplateListParams = {
  resource_id?: string;
  status?: string;
  page?: number;
  page_size?: number;
};

function normalizeTemplatePayload<T extends { effective_from?: string; effective_to?: string }>(
  data: T,
): T {
  const out = { ...data };
  if (out.effective_from && !out.effective_from.includes('T')) {
    out.effective_from = `${out.effective_from}T00:00:00.000Z`;
  }
  if (out.effective_to && !out.effective_to.includes('T')) {
    out.effective_to = `${out.effective_to}T23:59:59.999Z`;
  }
  return out;
}

export const sessionApi = {
  templates: {
    list: (venueId: string, params: TemplateListParams = {}) =>
      api
        .get<PaginatedTemplates>(`/session/v1/venues/${venueId}/sessions/templates`, { params })
        .then((r) => r.data),

    create: (venueId: string, data: TemplateCreatePayload) =>
      api
        .post<SessionTemplate>(
          `/session/v1/venues/${venueId}/sessions/templates`,
          normalizeTemplatePayload(data),
        )
        .then((r) => r.data),

    get: (id: string) =>
      api.get<SessionTemplate>(`/session/v1/sessions/templates/${id}`).then((r) => r.data),

    update: (id: string, data: TemplateUpdatePayload) =>
      api
        .patch<SessionTemplate>(
          `/session/v1/sessions/templates/${id}`,
          normalizeTemplatePayload(data),
        )
        .then((r) => r.data),

    archive: (id: string) => api.delete(`/session/v1/sessions/templates/${id}`),

    regenerateInvite: (id: string) =>
      api
        .post<{ invite_code: string }>(`/session/v1/sessions/templates/${id}/invite`)
        .then((r) => r.data),
  },

  listForVenue: (venueId: string, params: OwnerSessionListParams = {}) =>
    api
      .get<PaginatedSessions>(`/session/v1/venues/${venueId}/sessions`, { params })
      .then((r) => r.data),

  createInstance: (venueId: string, data: OwnerSessionCreatePayload) =>
    api
      .post<SessionInstance>(`/session/v1/venues/${venueId}/sessions`, data)
      .then((r) => r.data),

  get: (id: string) =>
    api.get<SessionInstance>(`/session/v1/sessions/${id}`).then((r) => r.data),

  cancel: (id: string) => api.delete(`/session/v1/sessions/${id}`),

  participants: (id: string) =>
    api
      .get<SessionParticipantsOwner>(`/session/v1/sessions/${id}/participants`)
      .then((r) => r.data),
};
