import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { promoApi } from '@/api/promos';
import type { PromoCreatePayload, PromoUpdatePayload } from '@/types/promo';

function promoKey(venueId: string, resourceId?: string) {
  return ['venues', venueId, 'promos', resourceId ?? 'all'] as const;
}

/** Fetch all promos for a venue, optionally narrowed by resource */
export function usePromos(venueId: string, resourceId?: string) {
  return useQuery({
    queryKey: promoKey(venueId, resourceId),
    queryFn: () =>
      promoApi.listByVenue(venueId, {
        resource_id: resourceId,
        page_size: 200,
      }),
    enabled: !!venueId,
    select: (d) => d.results,
  });
}

export function useCreatePromo(venueId: string, resourceId?: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: PromoCreatePayload) => promoApi.create(venueId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: promoKey(venueId, resourceId) });
      qc.invalidateQueries({ queryKey: promoKey(venueId) });
    },
  });
}

export function useUpdatePromo(venueId: string, resourceId?: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: PromoUpdatePayload }) =>
      promoApi.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: promoKey(venueId, resourceId) });
      qc.invalidateQueries({ queryKey: promoKey(venueId) });
    },
  });
}

export function useDeletePromo(venueId: string, resourceId?: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => promoApi.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: promoKey(venueId, resourceId) });
      qc.invalidateQueries({ queryKey: promoKey(venueId) });
    },
  });
}
