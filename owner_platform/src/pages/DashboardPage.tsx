import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  BookOpenCheck,
  Wallet,
  Building2,
  ChevronRight,
  Plus,
  CalendarClock,
  BadgePercent,
  CheckCircle2,
} from 'lucide-react';

import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { StatusChip } from '@/components/common/StatusChip';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/dashboard/StatCard';
import { RevenueChart } from '@/components/dashboard/RevenueChart';
import { EmptyState } from '@/components/ui/EmptyState';

import { useAuth } from '@/store/auth';
import { formatInTimezone, formatPrice, formatShortDayFromIsoDate } from '@/lib/format';
import { localizedBookingStatus, localizedPaymentStatus } from '@/lib/bookingLabels';
import { bookingApi } from '@/api/bookings';
import { useMyVenues } from '@/hooks/useVenues';
import { useGuestDirectory } from '@/hooks/useBookings';
import { useOwnerDashboard } from '@/hooks/useOwnerDashboard';
import type { ApiBooking } from '@/types/booking';

export function DashboardPage() {
  const { t, i18n } = useTranslation();
  const user = useAuth((s) => s.user);
  const { data: venueData } = useMyVenues();
  const venues = venueData?.results ?? [];
  const venueIds = useMemo(() => venues.map((v: { id: string }) => v.id).filter(Boolean), [venues]);

  const venueNameById = useMemo(() => {
    const m = new Map<string, string>();
    for (const v of venues as { id: string; name?: string }[]) {
      m.set(v.id, v.name ?? v.id);
    }
    return m;
  }, [venues]);

  const { data: dash, isLoading: dashLoading } = useOwnerDashboard(7);

  const rev = dash?.revenue;
  const currency = rev?.currency ?? 'KZT';
  const chartPoints = useMemo(() => {
    const daily = rev?.daily ?? [];
    if (!daily.length) return [];
    return daily.map((d) => ({
      label: formatShortDayFromIsoDate(d.day, i18n.language),
      revenue: d.owner_net_minor,
      bookings: d.payment_count,
    }));
  }, [rev?.daily, i18n.language]);

  const revDelta = dash?.revenue_today_delta;
  const hasRevDelta = typeof revDelta === 'number' && Number.isFinite(revDelta);

  const { data: bookingsData } = useQuery({
    queryKey: ['bookings', 'dashboard-incoming', venueIds.join('|')],
    enabled: venueIds.length > 0,
    queryFn: () =>
      bookingApi.list({
        venue_ids: venueIds,
        from: new Date().toISOString(),
        page_size: 10,
        page: 0,
        sort: 'start_at',
        include_cancelled: false,
      }),
    staleTime: 60_000,
  });

  const firstName =
    user?.fullName?.trim()?.split(/\s+/)?.filter(Boolean)[0] ?? 'there';
  const incomingBookings = bookingsData?.results ?? [];
  const { byId: guestById } = useGuestDirectory(incomingBookings.map((b) => b.user_id));

  return (
    <div>
      <PageHeader
        eyebrow={t('dashboard.hello', { name: firstName })}
        title={t('dashboard.title')}
        subtitle={t('dashboard.subtitle')}
        actions={
          <Link to="/facilities">
            <Button leftIcon={<Plus size={16} />}>
              {t('dashboard.actionAddFacility')}
            </Button>
          </Link>
        }
      />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          icon={<BookOpenCheck size={20} />}
          label={t('dashboard.statBookingsToday')}
          value={dashLoading ? '—' : String(dash?.bookings_today ?? 0)}
          delta={dash?.bookings_today_delta}
          accent="brand"
        />
        <StatCard
          icon={<Wallet size={20} />}
          label={t('dashboard.statRevenueToday')}
          value={
            dashLoading
              ? '—'
              : formatPrice(rev?.today.owner_net_minor ?? 0, currency)
          }
          delta={dash?.revenue_today_delta}
          accent="success"
        />
        <StatCard
          icon={<CheckCircle2 size={20} />}
          label={t('dashboard.statPaymentsToday')}
          value={dashLoading ? '—' : String(rev?.today.succeeded_count ?? 0)}
          delta={dash?.successful_payments_dod}
          accent="info"
        />
        <StatCard
          icon={<Building2 size={20} />}
          label={t('dashboard.statFacilities')}
          value={String(venues.length)}
          accent="warning"
        />
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-base font-extrabold text-text-light dark:text-text-dark">
                  {t('dashboard.revenueTrend')}
                </h3>
                <p className="text-xs text-muted-light dark:text-muted-dark">
                  {rev?.range_start && rev?.range_end
                    ? `${new Intl.DateTimeFormat(i18n.language, { month: 'short', day: 'numeric' }).format(new Date(rev.range_start))} – ${new Intl.DateTimeFormat(i18n.language, { month: 'short', day: 'numeric' }).format(new Date(rev.range_end))} · UTC`
                    : new Intl.DateTimeFormat(i18n.language, {
                        month: 'short',
                        day: 'numeric',
                      }).format(new Date())}
                </p>
              </div>
              {hasRevDelta ? (
                <Badge tone={revDelta! >= 0 ? 'success' : 'danger'}>
                  {revDelta! >= 0 ? '+' : ''}
                  {Math.round(revDelta! * 100)}%
                </Badge>
              ) : null}
            </div>
          </CardHeader>
          <CardBody>
            <RevenueChart data={chartPoints} />
          </CardBody>
        </Card>

        <Card>
          <CardHeader>
            <h3 className="text-base font-extrabold">
              {t('dashboard.quickActions')}
            </h3>
          </CardHeader>
          <CardBody className="space-y-3">
            <QuickAction
              icon={<Plus size={18} />}
              label={t('dashboard.actionAddFacility')}
              to="/facilities"
              tone="brand"
            />
            <QuickAction
              icon={<CalendarClock size={18} />}
              label={t('dashboard.actionEditSchedule')}
              to="/facilities"
              tone="info"
            />
            <QuickAction
              icon={<BadgePercent size={18} />}
              label={t('dashboard.actionAdjustPrices')}
              to="/facilities"
              tone="warning"
            />
          </CardBody>
        </Card>
      </div>

      <div className="mt-6">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h3 className="text-base font-extrabold">
                {t('dashboard.incomingBookings')}
              </h3>
              <Link
                to="/bookings"
                className="text-sm font-semibold text-brand-600 dark:text-brand-300 hover:underline"
              >
                {t('dashboard.seeAll')}
              </Link>
            </div>
          </CardHeader>
          <CardBody>
            {incomingBookings.length === 0 ? (
              <EmptyState
                icon={<CalendarClock size={22} />}
                title={t('dashboard.noIncoming')}
              />
            ) : (
              <div className="divide-y divide-black/5 dark:divide-white/10">
                {incomingBookings.map((b: ApiBooking) => (
                  <BookingRow
                    key={b.id}
                    booking={b}
                    venueName={venueNameById.get(b.venue_id) ?? b.venue_id}
                    guestLabel={guestById[b.user_id]?.displayName ?? '—'}
                  />
                ))}
              </div>
            )}
          </CardBody>
        </Card>
      </div>

      <div className="mt-6">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h3 className="text-base font-extrabold">
                {t('facilities.title')}
              </h3>
              <Link
                to="/facilities"
                className="text-sm font-semibold text-brand-600 dark:text-brand-300 hover:underline"
              >
                {t('dashboard.seeAll')}
              </Link>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {venues.slice(0, 3).map((v: { id: string; name?: string; images?: string[]; city?: string; country?: string; status?: 'active' | 'draft' | 'suspended' | 'inactive' | 'maintenance' }) => (
                <Link
                  key={v.id}
                  to={`/facilities/${v.id}`}
                  className="group block overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.02] transition-shadow hover:shadow-card"
                >
                  <div className="relative h-36 overflow-hidden">
                    {v.images?.[0] ? (
                      <img
                        src={v.images[0]}
                        alt={v.name ?? ''}
                        className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                      />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-brand-500/25 to-brand-700/20 text-sm font-bold text-brand-800 dark:text-brand-200">
                        {v.name ?? v.id}
                      </div>
                    )}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                    <div className="absolute top-3 right-3">
                      <StatusChip status={v.status ?? 'draft'} />
                    </div>
                    <div className="absolute bottom-3 left-3 text-white">
                      <div className="text-sm font-extrabold drop-shadow">
                        {v.name}
                      </div>
                      <div className="text-xs opacity-90">
                        {v.city}, {v.country}
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </CardBody>
        </Card>
      </div>
    </div>
  );
}

function BookingRow({
  booking,
  venueName,
  guestLabel,
}: {
  booking: ApiBooking;
  venueName: string;
  guestLabel: string;
}) {
  const { t, i18n } = useTranslation();

  const currency = booking.currency ?? 'KZT';
  const priceNum =
    typeof booking.price_total === 'string'
      ? Number.parseInt(booking.price_total, 10)
      : Number(booking.price_total);

  const s = booking.status.toLowerCase();
  const tone =
    s === 'confirmed' || s === 'completed'
      ? 'success'
      : s === 'created' || s === 'pending'
        ? 'warning'
        : s === 'cancelled'
          ? 'danger'
          : 'neutral';

  const resourceShort =
    booking.resource_id.length > 10 ? `${booking.resource_id.slice(0, 8)}…` : booking.resource_id;

  return (
    <div className="flex items-center gap-3 py-3">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-500 text-sm font-bold text-white">
        {guestLabel[0]?.toUpperCase() ?? '?'}
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <div className="truncate text-sm font-bold">{guestLabel}</div>
          <Badge tone={tone as 'success' | 'warning' | 'info' | 'danger' | 'neutral'}>
            {localizedBookingStatus(t, booking.status)}
          </Badge>
          <span className="text-[10px] font-semibold uppercase tracking-wide text-muted-light dark:text-muted-dark">
            {localizedPaymentStatus(t, booking.payment_status)}
          </span>
        </div>
        <div className="mt-0.5 truncate text-xs text-muted-light dark:text-muted-dark">
          {venueName} · {resourceShort}
        </div>
      </div>
      <div className="hidden sm:block text-right">
        <div className="text-sm font-semibold">
          {formatInTimezone(booking.start_at, booking.timezone, i18n.language, {
            weekday: 'short',
            day: 'numeric',
            month: 'short',
          })}
        </div>
        <div className="text-xs text-muted-light dark:text-muted-dark">
          {formatInTimezone(booking.start_at, booking.timezone, i18n.language, {
            hour: '2-digit',
            minute: '2-digit',
          })}{' '}
          –{' '}
          {formatInTimezone(booking.end_at, booking.timezone, i18n.language, {
            hour: '2-digit',
            minute: '2-digit',
          })}
        </div>
      </div>
      <div className="hidden md:block text-right w-28">
        <div className="text-sm font-bold text-brand-700 dark:text-brand-300">
          {formatPrice(Number.isNaN(priceNum) ? 0 : priceNum, currency)}
        </div>
      </div>
    </div>
  );
}

function QuickAction({
  icon,
  label,
  to,
  tone,
  disabled,
}: {
  icon: React.ReactNode;
  label: string;
  to: string;
  tone: 'brand' | 'info' | 'warning' | 'neutral';
  disabled?: boolean;
}) {
  const toneClasses: Record<typeof tone, string> = {
    brand: 'bg-brand-500/10 text-brand-700 dark:text-brand-300',
    info: 'bg-info/10 text-info',
    warning: 'bg-warning/15 text-[#b4700a] dark:text-warning',
    neutral: 'bg-black/5 text-muted-light dark:bg-white/10 dark:text-muted-dark',
  };
  const content = (
    <div
      className={`flex items-center gap-3 rounded-lg px-3 py-2.5 transition-colors ${
        disabled ? 'opacity-60 cursor-not-allowed' : 'hover:bg-black/[0.04] dark:hover:bg-white/[0.06]'
      }`}
    >
      <span className={`flex h-9 w-9 items-center justify-center rounded-md ${toneClasses[tone]}`}>
        {icon}
      </span>
      <span className="flex-1 text-sm font-semibold">{label}</span>
      <ChevronRight size={16} className="text-muted-light dark:text-muted-dark" />
    </div>
  );
  if (disabled) return content;
  return <Link to={to}>{content}</Link>;
}
