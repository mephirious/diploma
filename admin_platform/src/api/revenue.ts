import { api } from './client';

export type AdminRevenueDashboard = {
  currency: string;
  platform_fee_percent: number;
  venue_count: number;
  period_days: number;
  range_start: string;
  range_end: string;
  totals: {
    gross_minor: number;
    refund_minor: number;
    owner_refund_minor?: number;
    net_gross_minor?: number;
    platform_minor: number;
    owner_net_minor: number;
    succeeded_count: number;
    refund_count: number;
    failed_count: number;
    expired_count: number;
  };
  today: {
    gross_minor: number;
    refund_minor?: number;
    platform_minor: number;
    succeeded_count: number;
  };
  daily: Array<{
    day: string;
    gross_minor: number;
    refund_minor?: number;
    platform_minor: number;
    payment_count: number;
  }>;
};

export const adminRevenueApi = {
  dashboard: (days = 30) =>
    api
      .get<AdminRevenueDashboard>('/payment/v1/admin/revenue', { params: { days } })
      .then((r) => r.data),
};
