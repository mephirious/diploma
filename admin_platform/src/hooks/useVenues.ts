import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminVenueApi, type VenueContactPayload, type VenueCreatePayload } from '@/api/venues';

export function useMyVenues() {
  return useQuery({
    queryKey: ['venues', 'my'],
    queryFn: () =>
      adminVenueApi
        .listVenues({ status: 'active', page_size: 100 })
        .then((data) => ({ ...data, results: data.venues })),
  });
}

export function useVenue(id: string) {
  return useQuery({
    queryKey: ['venues', id],
    queryFn: () => adminVenueApi.get(id),
    enabled: !!id,
  });
}

export function useCreateVenue() {
  return useMutation({
    mutationFn: async (_data: VenueCreatePayload) => {
      throw new Error('Admin venue creation is not available');
    },
  });
}

export function useUpdateVenue(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<VenueCreatePayload>) => adminVenueApi.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', id] });
      qc.invalidateQueries({ queryKey: ['venues', 'my'] });
    },
  });
}

export function useDeleteVenue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminVenueApi.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', 'my'] });
      qc.invalidateQueries({ queryKey: ['admin-venues'] });
    },
  });
}

export function useCreateVenueContact(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (contact: VenueContactPayload) => adminVenueApi.contacts.create(venueId, contact),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId] }),
  });
}

export function useUpdateVenueContact(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ index, contact }: { index: number; contact: VenueContactPayload }) =>
      adminVenueApi.contacts.update(venueId, index, contact),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId] }),
  });
}

export function useDeleteVenueContact(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (index: number) => adminVenueApi.contacts.delete(venueId, index),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId] }),
  });
}

export function useVenueResources(venueId: string) {
  return useQuery({
    queryKey: ['venues', venueId, 'resources'],
    queryFn: () => adminVenueApi.resources.list(venueId),
    enabled: !!venueId,
  });
}

export function useScheduleResult(venueId: string) {
  return useQuery({
    queryKey: ['venues', venueId, 'schedule-result'],
    queryFn: () => adminVenueApi.schedules.result(venueId),
    enabled: !!venueId,
  });
}

export function useCreateResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Parameters<typeof adminVenueApi.resources.create>[1]) =>
      adminVenueApi.resources.create(venueId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useUpdateResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_payload: { id: string; data: unknown }) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useDeleteResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_id: string) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useCreateSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_data: unknown) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdateSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_payload: { id: string; data: unknown }) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeleteSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_id: string) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useCreatePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_data: unknown) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdatePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_payload: { id: string; data: unknown }) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeletePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_id: string) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useCreateBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_data: unknown) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdateBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_payload: { id: string; data: unknown }) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeleteBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (_id: string) => {
      throw new Error('Admin resource detail editing is not available');
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}
