import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { bookingApi, type BookingStatsParams } from '@/api/bookings';

export function useBookings(params: Parameters<typeof bookingApi.list>[0] = {}) {
  return useQuery({
    queryKey: ['bookings', params],
    queryFn: () => bookingApi.list(params),
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
