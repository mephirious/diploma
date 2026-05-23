import { useQuery } from '@tanstack/react-query';
import { fetchOwnerDashboard } from '@/api/dashboard';

export function useOwnerDashboard(days = 7, venueId?: string) {
  return useQuery({
    queryKey: ['owner-dashboard', days, venueId ?? ''],
    queryFn: () => fetchOwnerDashboard({ days, venue_id: venueId || undefined }),
    staleTime: 60_000,
  });
}
