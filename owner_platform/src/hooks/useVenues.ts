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
