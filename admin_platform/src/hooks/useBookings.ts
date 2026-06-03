import {
  useQuery,
  useMutation,
  useQueryClient,
  useInfiniteQuery,
  useQueries,
} from '@tanstack/react-query';
import { bookingApi, type BookingStatsParams } from '@/api/bookings';
import { accountApi } from '@/api/account';

export function useBookings(params: Parameters<typeof bookingApi.list>[0] = {}) {
  return useQuery({
    queryKey: ['bookings', params],
    queryFn: () => bookingApi.list(params),
  });
}

/** Paged owner list; `from` / `to` boundary is computed fresh on each fetch (UTC “now”). */
export function useOwnerBookingsInfinite(opts: {
  venue_ids: string[];
  resource_id?: string;
  enabled?: boolean;
  tab: 'upcoming' | 'past';
  page_size?: number;
  refetchInterval?: number | false;
}) {
  const {
    venue_ids,
    resource_id,
    enabled = true,
    tab,
    page_size: pageSize = 30,
    refetchInterval,
  } = opts;

  const sort = tab === 'upcoming' ? 'start_at' : '-end_at';
  const include_cancelled = tab === 'past';

  return useInfiniteQuery({
    queryKey: ['bookings', 'owner-infinite', venue_ids, resource_id ?? '', tab, sort, pageSize],
    enabled: enabled && venue_ids.length > 0,
    refetchInterval: refetchInterval === undefined ? false : refetchInterval,
    initialPageParam: 0,
    queryFn: ({ pageParam }) => {
      const boundary = new Date().toISOString();
      return bookingApi.list({
        venue_ids,
        resource_id,
        page: pageParam,
        page_size: pageSize,
        with_total_count: true,
        sort,
        include_cancelled,
        from: tab === 'upcoming' ? boundary : undefined,
        to: tab === 'past' ? boundary : undefined,
      });
    },
    getNextPageParam: (lastPage, allPages, lastPageParam) => {
      const total = Number(lastPage.pagination_info?.total_count ?? 0);
      const loaded = allPages.reduce((acc, p) => acc + p.results.length, 0);
      if (lastPage.results.length < pageSize) return undefined;
      if (total > 0 && loaded >= total) return undefined;
      return lastPageParam + 1;
    },
  });
}

export function useBookingStats(params: BookingStatsParams) {
  return useQuery({
    queryKey: ['bookings', 'stats', params],
    queryFn: () => bookingApi.stats(params),
    enabled: params.venue_ids.length > 0,
  });
}

export function useConfirmBooking() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => bookingApi.confirm(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['bookings'] }),
  });
}

export function useCancelBooking() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason?: string }) =>
      bookingApi.cancel(id, reason),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['bookings'] }),
  });
}

export function shortUserId(id: string) {
  return id.length > 12 ? `${id.slice(0, 8)}…` : id;
}

/** Resolve guest display names for booking rows (cached per user id). */
export function useGuestDirectory(userIds: string[]) {
  const unique = [...new Set(userIds.map((x) => x.trim()).filter(Boolean))].sort();
  const queries = useQueries({
    queries: unique.map((id) => ({
      queryKey: ['account', 'user', id],
      queryFn: () => accountApi.getUser(id),
      staleTime: 300_000,
      retry: 1,
    })),
  });

  const byId: Record<string, { displayName: string; email?: string; loading: boolean }> = {};
  unique.forEach((id, i) => {
    const q = queries[i];
    if (!q) return;
    if (q.isLoading || q.isFetching) {
      byId[id] = { displayName: shortUserId(id), loading: true };
      return;
    }
    const data = q.data;
    if (!data) {
      byId[id] = { displayName: shortUserId(id), loading: false };
      return;
    }
    const name = [data.first_name, data.last_name].filter(Boolean).join(' ').trim();
    byId[id] = {
      displayName: name || data.username || data.email || shortUserId(id),
      email: data.email,
      loading: false,
    };
  });

  return { byId };
}
