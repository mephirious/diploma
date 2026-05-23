import { api } from './client';
import type { OwnerRevenueDashboard } from './revenue';

export type OwnerDashboardResponse = {
  revenue: OwnerRevenueDashboard;
  bookings_today: number;
  bookings_yesterday: number;
  bookings_today_delta?: number;
  revenue_today_delta?: number;
  successful_payments_dod?: number;
};

export async function fetchOwnerDashboard(params: {
  days?: number;
  venue_id?: string;
}): Promise<OwnerDashboardResponse> {
  const { data } = await api.get<OwnerDashboardResponse>('/payment/v1/owner/dashboard', {
    params: {
      days: params.days ?? 7,
      ...(params.venue_id ? { venue_id: params.venue_id } : {}),
    },
  });
  return data;
}
