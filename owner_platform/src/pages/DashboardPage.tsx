import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  BookOpenCheck,
  Wallet,
  Users,
  Building2,
  ChevronRight,
  Plus,
  CalendarClock,
  BadgePercent,
  UserPlus,
} from 'lucide-react';

import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { StatusChip } from '@/components/common/StatusChip';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/dashboard/StatCard';
import { RevenueChart } from '@/components/dashboard/RevenueChart';
import { OccupancyHeatmap } from '@/components/dashboard/OccupancyHeatmap';
import { EmptyState } from '@/components/ui/EmptyState';

import { useAuth } from '@/store/auth';
import {
  MOCK_DASHBOARD_STATS,
  MOCK_INCOMING_BOOKINGS,
} from '@/mock/dashboard';
import { MOCK_VENUES } from '@/mock/venues';
import { formatPrice } from '@/lib/format';

export function DashboardPage() {
  const { t, i18n } = useTranslation();
  const user = useAuth((s) => s.user);

  const firstName = user?.fullName.split(' ')[0] ?? 'there';

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
          value={String(MOCK_DASHBOARD_STATS.bookingsToday)}
          delta={MOCK_DASHBOARD_STATS.bookingsTodayDelta}
          accent="brand"
        />
        <StatCard
          icon={<Wallet size={20} />}
          label={t('dashboard.statRevenueToday')}
          value={formatPrice(
            MOCK_DASHBOARD_STATS.revenueToday,
            MOCK_DASHBOARD_STATS.currency,
          )}
          delta={MOCK_DASHBOARD_STATS.revenueTodayDelta}
          accent="success"
        />
        <StatCard
          icon={<Users size={20} />}
          label={t('dashboard.statOccupancy')}
          value={`${Math.round(MOCK_DASHBOARD_STATS.occupancyWeek * 100)}%`}
          delta={MOCK_DASHBOARD_STATS.occupancyWeekDelta}
          accent="info"
        />
        <StatCard
          icon={<Building2 size={20} />}
          label={t('dashboard.statFacilities')}
          value={String(MOCK_DASHBOARD_STATS.activeFacilities)}
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
                  {new Intl.DateTimeFormat(i18n.language, {
                    month: 'short',
                    day: 'numeric',
                  }).format(new Date())}
                </p>
              </div>
              <Badge tone="success">
                +{Math.round(MOCK_DASHBOARD_STATS.revenueTodayDelta * 100)}%
              </Badge>
            </div>
          </CardHeader>
          <CardBody>
            <RevenueChart />
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
            <QuickAction
              icon={<UserPlus size={18} />}
              label={t('dashboard.actionInvitePartner')}
              to="#"
              tone="neutral"
              disabled
            />
          </CardBody>
        </Card>
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-3">
        <Card className="xl:col-span-2">
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
            {MOCK_INCOMING_BOOKINGS.length === 0 ? (
              <EmptyState
                icon={<CalendarClock size={22} />}
                title={t('dashboard.noIncoming')}
              />
            ) : (
              <div className="divide-y divide-black/5 dark:divide-white/10">
                {MOCK_INCOMING_BOOKINGS.map((b) => (
                  <BookingRow key={b.id} booking={b} />
                ))}
              </div>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader>
            <h3 className="text-base font-extrabold">
              {t('dashboard.popularSlots')}
            </h3>
          </CardHeader>
          <CardBody>
            <OccupancyHeatmap />
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
              {MOCK_VENUES.slice(0, 3).map((v) => (
                <Link
                  key={v.id}
                  to={`/facilities/${v.id}`}
                  className="group block overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.02] transition-shadow hover:shadow-card"
                >
                  <div className="relative h-36 overflow-hidden">
                    <img
                      src={v.images[0]}
                      alt={v.name}
                      className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                    <div className="absolute top-3 right-3">
                      <StatusChip status={v.status} />
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

function BookingRow({ booking }: { booking: (typeof MOCK_INCOMING_BOOKINGS)[number] }) {
  const { t, i18n } = useTranslation();

  const start = new Date(booking.start_at);
  const end = new Date(booking.end_at);
  const tone =
    booking.status === 'confirmed'
      ? 'success'
      : booking.status === 'completed'
        ? 'info'
        : booking.status === 'pending'
          ? 'warning'
          : 'danger';

  return (
    <div className="flex items-center gap-3 py-3">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-500 text-sm font-bold text-white">
        {booking.customer_name[0]}
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <div className="truncate text-sm font-bold">{booking.customer_name}</div>
          <Badge tone={tone as 'success' | 'warning' | 'info' | 'danger'}>
            {t(`booking.status.${booking.status}`)}
          </Badge>
        </div>
        <div className="mt-0.5 truncate text-xs text-muted-light dark:text-muted-dark">
          {booking.facility_name} · {booking.resource_name}
        </div>
      </div>
      <div className="hidden sm:block text-right">
        <div className="text-sm font-semibold">
          {new Intl.DateTimeFormat(i18n.language, {
            weekday: 'short',
            day: 'numeric',
            month: 'short',
          }).format(start)}
        </div>
        <div className="text-xs text-muted-light dark:text-muted-dark">
          {formatRange(start, end, i18n.language)}
        </div>
      </div>
      <div className="hidden md:block text-right w-24">
        <div className="text-sm font-bold text-brand-700 dark:text-brand-300">
          {formatPrice(booking.price, booking.currency)}
        </div>
        <div className="text-[11px] text-muted-light dark:text-muted-dark">
          {booking.attendees} ppl
        </div>
      </div>
    </div>
  );
}

function formatRange(start: Date, end: Date, locale: string) {
  const fmt = new Intl.DateTimeFormat(locale, { hour: '2-digit', minute: '2-digit' });
  return `${fmt.format(start)} – ${fmt.format(end)}`;
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
