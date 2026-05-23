import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { venueApi, type VenueCreatePayload } from '@/api/venues';
import { useAuth } from '@/store/auth';

export function useMyVenues() {
  const userId = useAuth((s) => s.user?.id);
  return useQuery({
    queryKey: ['venues', 'my', userId],
    queryFn: () => venueApi.list({ owner_id: userId }),
    enabled: !!userId,
  });
}

export function useVenue(id: string) {
  return useQuery({
    queryKey: ['venues', id],
    queryFn: () => venueApi.get(id),
    enabled: !!id,
  });
}

export function useCreateVenue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: VenueCreatePayload) => venueApi.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', 'my'] }),
  });
}

export function useUpdateVenue(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<VenueCreatePayload>) => venueApi.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', id] });
      qc.invalidateQueries({ queryKey: ['venues', 'my'] });
    },
  });
}

export function useDeleteVenue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => venueApi.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', 'my'] }),
  });
}

export function useVenueResources(venueId: string) {
  return useQuery({
    queryKey: ['venues', venueId, 'resources'],
    queryFn: () => venueApi.resources.list(venueId),
    enabled: !!venueId,
  });
}

export function useScheduleResult(venueId: string) {
  return useQuery({
    queryKey: ['venues', venueId, 'schedule-result'],
    queryFn: () => venueApi.schedules.result(venueId),
    enabled: !!venueId,
  });
}

export function useCreateResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Parameters<typeof venueApi.resources.create>[1]) =>
      venueApi.resources.create(venueId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useUpdateResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Parameters<typeof venueApi.resources.update>[1] }) =>
      venueApi.resources.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useDeleteResource(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => venueApi.resources.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'resources'] });
      qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] });
    },
  });
}

export function useCreateSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Parameters<typeof venueApi.schedules.create>[1]) =>
      venueApi.schedules.create(venueId, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdateSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Parameters<typeof venueApi.schedules.update>[1] }) =>
      venueApi.schedules.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeleteSchedule(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => venueApi.schedules.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useCreatePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Parameters<typeof venueApi.pricing.create>[1]) =>
      venueApi.pricing.create(venueId, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdatePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Parameters<typeof venueApi.pricing.update>[1] }) =>
      venueApi.pricing.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeletePricing(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => venueApi.pricing.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useCreateBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Parameters<typeof venueApi.blackouts.create>[1]) =>
      venueApi.blackouts.create(venueId, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useUpdateBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Parameters<typeof venueApi.blackouts.update>[1] }) =>
      venueApi.blackouts.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}

export function useDeleteBlackout(venueId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => venueApi.blackouts.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['venues', venueId, 'schedule-result'] }),
  });
}
