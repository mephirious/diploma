import { useMemo, useState } from 'react';
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
import {
  Building2,
  Calendar,
  CheckCircle2,
  Landmark,
  RefreshCw,
  TrendingUp,
  Wallet,
  XCircle,
} from 'lucide-react';

import { StatCard } from '@/components/dashboard/StatCard';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { EmptyState } from '@/components/ui/EmptyState';
import { formatPrice } from '@/lib/format';
import { useOwnerRevenue } from '@/hooks/useOwnerRevenue';
import { useMyVenues } from '@/hooks/useVenues';
import { useTheme } from '@/store/theme';

const PERIODS = [7, 30, 90] as const;

export function RevenuePage() {
  const { t, i18n } = useTranslation();
  const [days, setDays] = useState<number>(30);
  const [venueId, setVenueId] = useState<string>('');
  const { data: venuesData } = useMyVenues();
  const venues = venuesData?.results ?? [];

  const { data, isLoading, isError, refetch, isFetching } = useOwnerRevenue(days, venueId || undefined);

  useTheme((s) => s.mode);
  const isDark = typeof document !== 'undefined' && document.documentElement.classList.contains('dark');
  const axisColor = isDark ? '#94A3B8' : '#6B7280';
  const gridColor = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)';

  const chartData = useMemo(() => {
    const daily = data?.daily ?? [];
    if (!daily.length) return [];
    return daily.map((d) => ({
      ...d,
      label: formatChartDay(d.day, i18n.language),
    }));
  }, [data?.daily, i18n.language]);

  const currency = data?.currency ?? 'KZT';

  return (
    <div>
      <section className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-brand-600 via-brand-500 to-emerald-600 p-6 sm:p-8 text-white shadow-xl mb-8">
        <div className="pointer-events-none absolute -right-16 -top-16 h-56 w-56 rounded-full bg-white/10 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-20 -left-10 h-48 w-48 rounded-full bg-black/10 blur-3xl" />
        <div className="relative flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-white/80">
              ZhamSpace Pay
            </p>
            <h1 className="mt-1 text-2xl sm:text-3xl font-extrabold tracking-tight">
              {t('revenue.title')}
            </h1>
            <p className="mt-2 max-w-xl text-sm text-white/90 leading-relaxed">
              {t('revenue.subtitle')}
            </p>
          </div>
          {data ? (
            <Badge tone="neutral" className="self-start border-white/25 bg-white/15 text-white">
              {t('revenue.feeBadge', { percent: data.platform_fee_percent })}
            </Badge>
          ) : null}
        </div>

        <div className="relative mt-6 flex flex-col gap-3 sm:flex-row sm:flex-wrap sm:items-center">
          <div className="flex flex-wrap gap-2">
            {PERIODS.map((d) => (
              <button
                key={d}
                type="button"
                onClick={() => setDays(d)}
                className={`rounded-full px-4 py-1.5 text-sm font-bold transition-colors ${
                  days === d
                    ? 'bg-white text-brand-700 shadow-md'
                    : 'bg-white/15 text-white hover:bg-white/25'
                }`}
              >
                {d === 7 ? t('revenue.period7') : d === 30 ? t('revenue.period30') : t('revenue.period90')}
              </button>
            ))}
          </div>
          <div className="flex flex-1 flex-col gap-2 sm:flex-row sm:items-center sm:justify-end">
            <label className="flex items-center gap-2 text-sm font-semibold text-white/90">
              <Building2 size={16} className="opacity-90" />
              <span className="sr-only sm:not-sr-only">{t('revenue.filterVenue')}</span>
              <select
                value={venueId}
                onChange={(e) => setVenueId(e.target.value)}
                className="min-w-[10rem] rounded-lg border border-white/25 bg-white/10 px-3 py-2 text-sm font-semibold text-white backdrop-blur outline-none focus:ring-2 focus:ring-white/40"
              >
                <option value="">{t('revenue.filterAllVenues')}</option>
                {venues.map((v: { id: string; name: string }) => (
                  <option key={v.id} value={v.id} className="text-text-light">
                    {v.name}
                  </option>
                ))}
              </select>
            </label>
            <Button
              type="button"
              variant="outline"
              className="border-white/30 bg-white/10 text-white hover:bg-white/20"
              leftIcon={<RefreshCw size={16} className={isFetching ? 'animate-spin' : ''} />}
              onClick={() => refetch()}
            >
              {t('common.retry')}
            </Button>
          </div>
        </div>
      </section>

      {isError ? (
        <Card className="border-danger/30 bg-danger/5">
          <CardBody className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-center gap-3 text-danger">
              <XCircle size={22} />
              <span className="font-semibold">{t('revenue.loadError')}</span>
            </div>
            <Button type="button" onClick={() => refetch()}>
              {t('common.retry')}
            </Button>
          </CardBody>
        </Card>
      ) : null}

      {!isLoading && data && data.venue_count === 0 ? (
        <EmptyState
          icon={<Building2 size={22} />}
          title={t('revenue.noVenues')}
          className="mt-6"
        />
      ) : null}

      {isLoading ? (
        <div className="mt-6 text-sm font-semibold text-muted-light dark:text-muted-dark">
          {t('common.loading')}
        </div>
      ) : data && data.venue_count > 0 ? (
        <>
          <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard
              icon={<TrendingUp size={20} />}
              label={t('revenue.gross')}
              value={formatPrice(data.totals.gross_minor, currency)}
              accent="brand"
            />
            <StatCard
              icon={<Wallet size={20} />}
              label={t('revenue.ownerNet')}
              value={formatPrice(data.totals.owner_net_minor, currency)}
              accent="success"
            />
            <StatCard
              icon={<Landmark size={20} />}
              label={t('revenue.platformFee')}
              value={formatPrice(data.totals.platform_minor, currency)}
              accent="warning"
            />
            <StatCard
              icon={<CheckCircle2 size={20} />}
              label={t('revenue.successCount')}
              value={String(data.totals.succeeded_count)}
              accent="info"
            />
          </div>

          <div className="mt-4 grid gap-4 md:grid-cols-3">
            <Card className="md:col-span-1">
              <CardBody>
                <div className="text-xs font-bold uppercase tracking-wider text-muted-light dark:text-muted-dark">
                  {t('revenue.today')}
                </div>
                <div className="mt-2 text-2xl font-extrabold text-text-light dark:text-text-dark">
                  {formatPrice(data.today.owner_net_minor, currency)}
                </div>
                <div className="mt-1 text-xs text-muted-light dark:text-muted-dark">
                  {formatPrice(data.today.gross_minor, currency)} · {data.today.succeeded_count}{' '}
                  {t('revenue.successCount').toLowerCase()}
                </div>
              </CardBody>
            </Card>
            <Card>
              <CardBody>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-muted-light dark:text-muted-dark">
                  <XCircle size={14} className="text-warning" />
                  {t('revenue.failed')}
                </div>
                <div className="mt-2 text-2xl font-extrabold">{data.totals.failed_count}</div>
              </CardBody>
            </Card>
            <Card>
              <CardBody>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-muted-light dark:text-muted-dark">
                  <Calendar size={14} />
                  {t('revenue.expired')}
                </div>
                <div className="mt-2 text-2xl font-extrabold">{data.totals.expired_count}</div>
              </CardBody>
            </Card>
          </div>

          <div className="mt-8 grid gap-6 xl:grid-cols-5">
            <Card className="xl:col-span-3">
              <CardHeader>
                <h3 className="text-base font-extrabold text-text-light dark:text-text-dark">
                  {t('revenue.chartTitle')}
                </h3>
                <p className="text-xs text-muted-light dark:text-muted-dark">{t('revenue.chartSubtitle')}</p>
              </CardHeader>
              <CardBody>
                {chartData.length === 0 ? (
                  <EmptyState icon={<TrendingUp size={22} />} title={t('revenue.empty')} />
                ) : (
                  <div className="h-72 w-full">
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={chartData} margin={{ left: 0, right: 8, top: 8, bottom: 0 }}>
                        <defs>
                          <linearGradient id="ownerNetFill" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="#00BFA5" stopOpacity={0.45} />
                            <stop offset="100%" stopColor="#00BFA5" stopOpacity={0} />
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="4 4" stroke={gridColor} vertical={false} />
                        <XAxis
                          dataKey="label"
                          stroke={axisColor}
                          tickLine={false}
                          axisLine={false}
                          fontSize={11}
                          interval="preserveStartEnd"
                        />
                        <YAxis
                          stroke={axisColor}
                          tickLine={false}
                          axisLine={false}
                          fontSize={11}
                          width={48}
                          tickFormatter={(v: number) => shortMoney(v, currency)}
                        />
                        <Tooltip
                          cursor={{ stroke: '#00BFA5', strokeOpacity: 0.15, strokeWidth: 28 }}
                          contentStyle={{
                            background: isDark ? '#1A2737' : '#FFFFFF',
                            borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.06)',
                            borderRadius: 12,
                            fontSize: 12,
                            padding: '8px 12px',
                            color: isDark ? '#F1F5F9' : '#1A1A2E',
                          }}
                          formatter={(val: number) => [formatPrice(val, currency), t('revenue.ownerNet')]}
                          labelFormatter={(_, p) => {
                            const day = p?.[0]?.payload?.day as string | undefined;
                            return day ?? '';
                          }}
                        />
                        <Area
                          type="monotone"
                          dataKey="owner_net_minor"
                          stroke="#00BFA5"
                          strokeWidth={2.5}
                          fill="url(#ownerNetFill)"
                          activeDot={{ r: 5, strokeWidth: 0 }}
                        />
                      </AreaChart>
                    </ResponsiveContainer>
                  </div>
                )}
              </CardBody>
            </Card>

            <Card className="xl:col-span-2">
              <CardHeader>
                <h3 className="text-base font-extrabold">{t('revenue.venuesTitle')}</h3>
              </CardHeader>
              <CardBody className="space-y-3">
                {!(data.venues ?? []).length ? (
                  <p className="text-sm text-muted-light dark:text-muted-dark">{t('revenue.empty')}</p>
                ) : (
                  (data.venues ?? []).map((v) => (
                    <div
                      key={v.venue_id}
                      className="flex items-center justify-between gap-3 rounded-xl border border-black/5 bg-black/[0.02] px-3 py-3 dark:border-white/10 dark:bg-white/[0.03]"
                    >
                      <div className="min-w-0">
                        <div className="truncate text-sm font-bold">{v.venue_name}</div>
                        <div className="text-[11px] text-muted-light dark:text-muted-dark">
                          {v.payment_count} · {formatPrice(v.gross_minor, currency)}
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-sm font-extrabold text-success">
                          {formatPrice(v.owner_net_minor, currency)}
                        </div>
                        <div className="text-[10px] text-muted-light dark:text-muted-dark">
                          {t('revenue.ownerNet')}
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </CardBody>
            </Card>
          </div>

          <Card className="mt-8">
            <CardHeader>
              <h3 className="text-base font-extrabold">{t('revenue.recentTitle')}</h3>
            </CardHeader>
            <CardBody className="overflow-x-auto p-0 sm:p-0">
              {!(data.recent ?? []).length ? (
                <div className="p-5">
                  <EmptyState icon={<CheckCircle2 size={22} />} title={t('revenue.empty')} />
                </div>
              ) : (
                <table className="w-full min-w-[640px] text-left text-sm">
                  <thead className="border-b border-black/5 bg-black/[0.02] text-[11px] font-bold uppercase tracking-wider text-muted-light dark:border-white/10 dark:bg-white/[0.04] dark:text-muted-dark">
                    <tr>
                      <th className="px-5 py-3">{t('revenue.colDate')}</th>
                      <th className="px-5 py-3">{t('revenue.colVenue')}</th>
                      <th className="px-5 py-3">{t('revenue.colBooking')}</th>
                      <th className="px-5 py-3">{t('revenue.colMethod')}</th>
                      <th className="px-5 py-3 text-right">{t('revenue.colGross')}</th>
                      <th className="px-5 py-3 text-right">{t('revenue.colNet')}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-black/5 dark:divide-white/10">
                    {(data.recent ?? []).map((r) => (
                      <tr key={r.id} className="hover:bg-black/[0.02] dark:hover:bg-white/[0.04]">
                        <td className="whitespace-nowrap px-5 py-3 text-muted-light dark:text-muted-dark">
                          {formatDateTime(r.succeeded_at, i18n.language)}
                        </td>
                        <td className="max-w-[10rem] truncate px-5 py-3 font-semibold">{r.venue_name}</td>
                        <td className="px-5 py-3 font-mono text-xs text-muted-light dark:text-muted-dark">
                          {r.booking_id.slice(0, 8)}…
                        </td>
                        <td className="px-5 py-3 capitalize">{methodLabel(r.payment_method)}</td>
                        <td className="px-5 py-3 text-right font-semibold">
                          {formatPrice(r.amount_minor, r.currency || currency)}
                        </td>
                        <td className="px-5 py-3 text-right font-extrabold text-success">
                          {formatPrice(r.owner_net_minor, r.currency || currency)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </CardBody>
          </Card>
        </>
      ) : null}
    </div>
  );
}

function formatChartDay(isoDay: string, locale: string) {
  const [y, m, d] = isoDay.split('-').map(Number);
  if (!y || !m || !d) return isoDay;
  const dt = new Date(Date.UTC(y, m - 1, d));
  return new Intl.DateTimeFormat(locale, { month: 'short', day: 'numeric' }).format(dt);
}

function formatDateTime(iso: string, locale: string) {
  const dt = new Date(iso);
  if (Number.isNaN(dt.getTime())) return '—';
  return new Intl.DateTimeFormat(locale, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(dt);
}

function shortMoney(n: number, currency: string) {
  if (currency === 'KZT') {
    if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
    if (n >= 1000) return `${(n / 1000).toFixed(0)}k`;
    return String(n);
  }
  return n >= 1000 ? `${(n / 1000).toFixed(0)}k` : String(n);
}

function methodLabel(m: string) {
  if (m === 'apple_pay') return 'Apple Pay';
  if (m === 'card') return 'Card';
  return m;
}
