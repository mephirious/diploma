import {
  useMutation,
  useQueries,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query';

import { sessionApi, type OwnerSessionListParams, type TemplateListParams } from '@/api/sessions';
import { accountApi } from '@/api/account';
import type {
  OwnerSessionCreatePayload,
  TemplateCreatePayload,
  TemplateUpdatePayload,
} from '@/types/session';
import { shortUserId } from '@/hooks/useBookings';

export function useSessionTemplates(venueId: string, params: TemplateListParams = {}) {
  return useQuery({
    queryKey: ['sessions', 'templates', venueId, params],
    queryFn: () => sessionApi.templates.list(venueId, params),
    enabled: !!venueId,
  });
}

export function useCreateSessionTemplate(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: TemplateCreatePayload) => sessionApi.templates.create(venueId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions', 'templates', venueId] });
    },
  });
}

export function useUpdateSessionTemplate(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: TemplateUpdatePayload }) =>
      sessionApi.templates.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions', 'templates', venueId] });
    },
  });
}

export function useArchiveSessionTemplate(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sessionApi.templates.archive(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions', 'templates', venueId] });
    },
  });
}

export function useRegenerateTemplateInvite(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sessionApi.templates.regenerateInvite(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions', 'templates', venueId] });
    },
  });
}

export function useCreateOwnerSession(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: OwnerSessionCreatePayload) => sessionApi.createInstance(venueId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions', 'owner'] });
    },
  });
}

export function useOwnerSessionsForVenues(
  venueIds: string[],
  params: Omit<OwnerSessionListParams, 'page'> & { page_size?: number },
) {
  const { page_size = 50, ...rest } = params;
  const queries = useQueries({
    queries: venueIds.map((venueId) => ({
      queryKey: ['sessions', 'owner', venueId, rest],
      queryFn: () => sessionApi.listForVenue(venueId, { ...rest, page: 1, page_size }),
      enabled: !!venueId,
      staleTime: 30_000,
    })),
  });

  const isLoading = queries.some((q) => q.isLoading);
  const isError = queries.some((q) => q.isError);
  const items = queries.flatMap((q) => q.data?.items ?? []);
  items.sort((a, b) => {
    const ta = new Date(a.starts_at).getTime();
    const tb = new Date(b.starts_at).getTime();
    return rest.timeframe === 'past' ? tb - ta : ta - tb;
  });

  return { items, isLoading, isError, queries };
}

export function useSessionParticipants(sessionId: string | null) {
  return useQuery({
    queryKey: ['sessions', 'participants', sessionId],
    queryFn: () => sessionApi.participants(sessionId!),
    enabled: !!sessionId,
  });
}

export function useCancelSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sessionApi.cancel(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['sessions'] });
    },
  });
}

export function useParticipantDirectory(userIds: string[]) {
  const unique = [...new Set(userIds.map((x) => x.trim()).filter(Boolean))].sort();
  const queries = useQueries({
    queries: unique.map((id) => ({
      queryKey: ['account', 'user', id],
      queryFn: () => accountApi.getUser(id),
      staleTime: 300_000,
      retry: 1,
    })),
  });

  const byId: Record<string, { displayName: string; email?: string }> = {};
  unique.forEach((id, i) => {
    const q = queries[i];
    const data = q?.data;
    if (!data) {
      byId[id] = { displayName: shortUserId(id) };
      return;
    }
    const name = [data.first_name, data.last_name].filter(Boolean).join(' ').trim();
    byId[id] = {
      displayName: name || data.username || data.email || shortUserId(id),
      email: data.email,
    };
  });

  return { byId, loading: queries.some((q) => q.isLoading) };
}
