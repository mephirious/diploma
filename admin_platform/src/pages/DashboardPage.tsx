import { useQuery } from '@tanstack/react-query';
import { Building2, CreditCard, Landmark, UsersRound } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';

import { adminApi } from '@/api/account';
import { adminRevenueApi } from '@/api/revenue';
import { adminVenueApi } from '@/api/venues';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { StatCard } from '@/components/ui/StatCard';
import { formatPrice } from '@/lib/format';

export function DashboardPage() {
  const { t } = useTranslation();
  const ownerStats = useQuery({ queryKey: ['admin-owner-stats'], queryFn: adminApi.stats });
  const venueStats = useQuery({ queryKey: ['admin-venue-stats'], queryFn: adminVenueApi.venueStats });
  const revenue = useQuery({
    queryKey: ['admin-revenue', 30],
    queryFn: () => adminRevenueApi.dashboard(30),
  });

  const data = revenue.data;
  const currency = data?.currency ?? 'KZT';
  const chartData =
    data?.daily.map((d) => ({
      day: d.day.slice(5),
      platform: d.platform_minor,
      gross: d.gross_minor,
    })) ?? [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold md:text-3xl">{t('dashboard.title')}</h1>
        <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
          {t('dashboard.subtitle')}
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard
          title={t('dashboard.activeOwners')}
          value={ownerStats.isLoading ? '...' : ownerStats.data?.total_active_owners ?? 0}
          icon={<UsersRound size={20} />}
        />
        <StatCard
          title={t('dashboard.activeVenues')}
          value={venueStats.isLoading ? '...' : venueStats.data?.total_active_venues ?? 0}
          icon={<Building2 size={20} />}
          tone="info"
        />
        <StatCard
          title={t('dashboard.companyRevenue')}
          value={
            revenue.isLoading
              ? '...'
              : formatPrice(data?.totals.platform_minor ?? 0, currency)
          }
          detail={t('dashboard.last30')}
          icon={<Landmark size={20} />}
          tone="success"
        />
        <StatCard
          title={t('dashboard.grossRevenue')}
          value={
            revenue.isLoading ? '...' : formatPrice(data?.totals.gross_minor ?? 0, currency)
          }
          detail={`${t('dashboard.payments')}: ${data?.totals.succeeded_count ?? 0}`}
          icon={<CreditCard size={20} />}
          tone="warning"
        />
      </div>

      <Card>
        <CardHeader>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="font-extrabold">{t('dashboard.revenueTrend')}</h2>
              <p className="text-sm text-muted-light dark:text-muted-dark">
                {t('dashboard.companyRevenue')} / {t('dashboard.grossRevenue')}
              </p>
            </div>
            {revenue.isError ? (
              <button
                type="button"
                onClick={() => void revenue.refetch()}
                className="text-sm font-semibold text-admin-600 hover:underline dark:text-admin-300"
              >
                {t('common.retry')}
              </button>
            ) : null}
          </div>
        </CardHeader>
        <CardBody>
          {revenue.isLoading ? (
            <div className="h-80 rounded-lg bg-black/[0.04] dark:bg-white/[0.06]" />
          ) : revenue.isError ? (
            <div className="rounded-lg border border-danger/20 bg-danger/5 p-4 text-sm text-danger">
              Failed to load revenue
            </div>
          ) : (
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="platformFill" x1="0" x2="0" y1="0" y2="1">
                      <stop offset="5%" stopColor="#5C6BC0" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#5C6BC0" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.25)" />
                  <XAxis dataKey="day" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} tickFormatter={(v) => `${Math.round(Number(v) / 1000)}k`} />
                  <Tooltip formatter={(value) => formatPrice(Number(value), currency)} />
                  <Area type="monotone" dataKey="gross" stroke="#94A3B8" fill="transparent" />
                  <Area
                    type="monotone"
                    dataKey="platform"
                    stroke="#5C6BC0"
                    fill="url(#platformFill)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}
        </CardBody>
      </Card>
    </div>
  );
}
