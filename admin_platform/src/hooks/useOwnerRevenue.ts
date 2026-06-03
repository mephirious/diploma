import { useQuery } from '@tanstack/react-query';
import { fetchOwnerRevenue } from '@/api/revenue';

export function useOwnerRevenue(days: number, venueId?: string) {
  return useQuery({
    queryKey: ['owner-revenue', days, venueId ?? ''],
    queryFn: () => fetchOwnerRevenue({ days, venue_id: venueId || undefined }),
    staleTime: 60_000,
  });
}
