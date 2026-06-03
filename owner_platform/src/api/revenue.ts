import { api } from './client';

export type OwnerRevenueDashboard = {
  currency: string;
  platform_fee_percent: number;
  venue_count: number;
  period_days: number;
  range_start: string;
  range_end: string;
  totals: {
    gross_minor: number;
    refund_minor: number;
    owner_refund_minor: number;
    net_gross_minor: number;
    platform_minor: number;
    owner_net_minor: number;
    succeeded_count: number;
    refund_count: number;
    failed_count: number;
    expired_count: number;
  };
  today: {
    gross_minor: number;
    refund_minor: number;
    owner_refund_minor: number;
    net_gross_minor: number;
    platform_minor: number;
    owner_net_minor: number;
    succeeded_count: number;
    refund_count: number;
  };
  daily: Array<{
    day: string;
    gross_minor: number;
    refund_minor: number;
    owner_refund_minor: number;
    net_gross_minor: number;
    owner_net_minor: number;
    platform_minor: number;
    payment_count: number;
    refund_count: number;
  }>;
  venues: Array<{
    venue_id: string;
    venue_name: string;
    gross_minor: number;
    refund_minor: number;
    owner_refund_minor: number;
    net_gross_minor: number;
    owner_net_minor: number;
    platform_minor: number;
    payment_count: number;
    refund_count: number;
  }> | null;
  recent: Array<{
    id: string;
    booking_id: string;
    venue_id: string;
    venue_name: string;
    amount_minor: number;
    refund_minor: number;
    owner_refund_minor: number;
    status: string;
    currency: string;
    payment_method: string;
    succeeded_at: string;
    refund_id?: string;
    refunded_at?: string;
    refund_reason?: string;
    event_at: string;
    platform_minor: number;
    owner_net_minor: number;
  }> | null;
};

export async function fetchOwnerRevenue(params: {
  days?: number;
  venue_id?: string;
}): Promise<OwnerRevenueDashboard> {
  const { data } = await api.get<OwnerRevenueDashboard>('/payment/v1/owner/revenue', {
    params: {
      days: params.days ?? 30,
      ...(params.venue_id ? { venue_id: params.venue_id } : {}),
    },
  });
  return data;
}
