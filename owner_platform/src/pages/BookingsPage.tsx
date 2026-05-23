import { useMemo, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import type { TFunction } from 'i18next';
import {
  CalendarClock,
  ChevronRight,
  Copy,
  Loader2,
  MapPin,
  UserRound,
  Wallet,
} from 'lucide-react';

import { PageHeader } from '@/components/common/PageHeader';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Tabs } from '@/components/ui/Tabs';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';

import { useMyVenues, useVenueResources } from '@/hooks/useVenues';
import { useCancelBooking, useGuestDirectory, useOwnerBookingsInfinite } from '@/hooks/useBookings';
import { localizedBookingStatus, localizedCancelReason, localizedPaymentStatus } from '@/lib/bookingLabels';
import { formatInTimezone, formatPrice } from '@/lib/format';
import type { ApiBooking } from '@/types/booking';
import { cn } from '@/lib/cn';

type TimeTab = 'upcoming' | 'past';

const PAGE_SIZE = 30;

export function BookingsPage() {
  const { t, i18n } = useTranslation();
  const [tab, setTab] = useState<TimeTab>('upcoming');
  const [venueFilter, setVenueFilter] = useState<string>(''); // '' = all owned venues
  const [resourceFilter, setResourceFilter] = useState<string>('');
  const [detail, setDetail] = useState<ApiBooking | null>(null);
  const [cancelTarget, setCancelTarget] = useState<ApiBooking | null>(null);

  const cancelMut = useCancelBooking();

  const { data: venueData } = useMyVenues();
  const venues = venueData?.results ?? [];

  const ownedVenueIds = useMemo(() => venues.map((v: { id: string }) => v.id).filter(Boolean), [venues]);

  const venueIdsForApi = useMemo(() => {
    if (venueFilter) return [venueFilter];
    return ownedVenueIds;
  }, [venueFilter, ownedVenueIds]);

  const venueNameById = useMemo(() => {
    const m = new Map<string, string>();
    for (const v of venues as { id: string; name?: string }[]) {
      m.set(v.id, v.name ?? v.id);
    }
    return m;
  }, [venues]);

  const listEnabled = venueIdsForApi.length > 0;

  const infinite = useOwnerBookingsInfinite({
    venue_ids: venueIdsForApi,
    resource_id: resourceFilter || undefined,
    enabled: listEnabled,
    tab,
    page_size: PAGE_SIZE,
    refetchInterval: tab === 'upcoming' ? 60_000 : false,
  });

  const flatBookings = useMemo(
    () => infinite.data?.pages.flatMap((p) => p.results) ?? [],
    [infinite.data?.pages],
  );

  const guestIds = useMemo(() => flatBookings.map((b) => b.user_id), [flatBookings]);
  const { byId: guestById } = useGuestDirectory(guestIds);

  const { data: resourcesData } = useVenueResources(venueFilter);
  const resources = resourcesData?.results ?? [];

  const detailVenueId = detail?.venue_id ?? '';
  const { data: detailResourcesData } = useVenueResources(detailVenueId);
  const detailResources = detailResourcesData?.results ?? [];

  const totalCount = Number(infinite.data?.pages[0]?.pagination_info?.total_count ?? 0);
  const hasNextPage = infinite.hasNextPage;

  function bookingBadgeTone(status: string): 'success' | 'warning' | 'info' | 'danger' | 'neutral' {
    const s = status.toLowerCase();
    if (s === 'confirmed' || s === 'completed') return 'success';
    if (s === 'created' || s === 'pending') return 'warning';
    if (s === 'cancelled') return 'danger';
    return 'neutral';
  }

  function paymentBadgeTone(payment: string): 'success' | 'warning' | 'info' | 'danger' | 'neutral' {
    const s = payment.toLowerCase();
    if (s === 'paid') return 'success';
    if (s === 'pending' || s === 'hold') return 'warning';
    if (s === 'failed') return 'danger';
    if (s === 'refunded') return 'info';
    return 'neutral';
  }

  function isLive(b: ApiBooking) {
    if (!b.start_at || !b.end_at) return false;
    const now = Date.now();
    const a = new Date(b.start_at).getTime();
    const z = new Date(b.end_at).getTime();
    return now >= a && now <= z && b.status?.toLowerCase() !== 'cancelled';
  }

  async function copyText(label: string, value: string) {
    try {
      await navigator.clipboard.writeText(value);
    } catch {
      window.prompt(label, value);
    }
  }

  return (
    <div>
      <PageHeader
        eyebrow={t('bookingsPage.eyebrow')}
        title={t('bookingsPage.title')}
        subtitle={t('bookingsPage.subtitle')}
      />

      <Card className="mt-6">
        <CardHeader>
          <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <Tabs<TimeTab>
              value={tab}
              onChange={(id) => {
                setTab(id);
                setResourceFilter('');
              }}
              items={[
                { id: 'upcoming', label: t('bookingsPage.tabUpcoming') },
                { id: 'past', label: t('bookingsPage.tabPast') },
              ]}
            />
            <div className="flex flex-wrap gap-3">
              <FilterSelect
                label={t('bookingsPage.filterVenue')}
                value={venueFilter}
                onChange={(v) => {
                  setVenueFilter(v);
                  setResourceFilter('');
                }}
              >
                <option value="">{t('bookingsPage.allVenues')}</option>
                {venues.map((v: { id: string; name?: string }) => (
                  <option key={v.id} value={v.id}>
                    {v.name ?? v.id}
                  </option>
                ))}
              </FilterSelect>
              <FilterSelect
                label={t('bookingsPage.filterResource')}
                value={resourceFilter}
                onChange={setResourceFilter}
                disabled={!venueFilter}
              >
                <option value="">{t('bookingsPage.allResources')}</option>
                {resources.map((r: { id: string; name?: string }) => (
                  <option key={r.id} value={r.id}>
                    {r.name ?? r.id}
                  </option>
                ))}
              </FilterSelect>
            </div>
          </div>
          <p className="mt-3 text-xs text-muted-light dark:text-muted-dark">{t('bookingsPage.filterHint')}</p>
        </CardHeader>
        <CardBody className="pt-0">
          {!listEnabled ? (
            <EmptyState
              icon={<CalendarClock size={22} />}
              title={t('bookingsPage.noVenuesTitle')}
              description={t('bookingsPage.noVenuesHint')}
            />
          ) : infinite.isError ? (
            <div className="rounded-lg border border-danger/30 bg-danger/10 px-4 py-3 text-sm font-semibold text-danger">
              {t('bookingsPage.loadError')}
            </div>
          ) : infinite.isLoading ? (
            <div className="flex items-center justify-center gap-2 py-16 text-muted-light dark:text-muted-dark">
              <Loader2 className="h-5 w-5 animate-spin" />
              {t('common.loading')}
            </div>
          ) : flatBookings.length === 0 ? (
            <EmptyState
              icon={<CalendarClock size={22} />}
              title={t('bookingsPage.emptyTitle')}
              description={t('bookingsPage.emptyHint')}
            />
          ) : (
            <>
              <div className="mb-4 flex flex-wrap items-center justify-between gap-2 text-xs font-semibold text-muted-light dark:text-muted-dark">
                <span>
                  {t('bookingsPage.showingCount', {
                    visible: flatBookings.length,
                    total: totalCount || flatBookings.length,
                  })}
                </span>
                <Button
                  type="button"
                  variant="ghost"
                  className="h-8 text-xs"
                  onClick={() => infinite.refetch()}
                  disabled={infinite.isFetching}
                >
                  {t('bookingsPage.refresh')}
                </Button>
              </div>

              <div className="hidden xl:block overflow-x-auto rounded-xl border border-black/5 dark:border-white/10">
                <table className="w-full min-w-[920px] border-collapse text-left text-sm">
                  <thead>
                    <tr className="border-b border-black/5 bg-black/[0.02] text-[11px] font-bold uppercase tracking-wide text-muted-light dark:border-white/10 dark:bg-white/[0.04] dark:text-muted-dark">
                      <th className="px-4 py-3">{t('bookingsPage.colWhen')}</th>
                      <th className="px-4 py-3">{t('bookingsPage.colFacility')}</th>
                      <th className="px-4 py-3">{t('bookingsPage.colGuest')}</th>
                      <th className="px-4 py-3">{t('bookingsPage.colBooking')}</th>
                      <th className="px-4 py-3">{t('bookingsPage.colPayment')}</th>
                      <th className="px-4 py-3 text-right">{t('bookingsPage.colAmount')}</th>
                      <th className="px-4 py-3 w-10" />
                    </tr>
                  </thead>
                  <tbody>
                    {flatBookings.map((b) => {
                      const guest = guestById[b.user_id];
                      const venueName = venueNameById.get(b.venue_id) ?? b.venue_id;
                      return (
                        <tr
                          key={b.id}
                          className="border-b border-black/5 transition-colors hover:bg-black/[0.02] dark:border-white/10 dark:hover:bg-white/[0.04]"
                        >
                          <td className="px-4 py-3 align-top">
                            <div className="flex flex-col gap-1">
                              <span className="font-bold text-text-light dark:text-text-dark">
                                {formatInTimezone(b.start_at, b.timezone, i18n.language, {
                                  weekday: 'short',
                                  day: 'numeric',
                                  month: 'short',
                                })}
                              </span>
                              <span className="text-xs text-muted-light dark:text-muted-dark">
                                {formatInTimezone(b.start_at, b.timezone, i18n.language, {
                                  hour: '2-digit',
                                  minute: '2-digit',
                                })}{' '}
                                –{' '}
                                {formatInTimezone(b.end_at, b.timezone, i18n.language, {
                                  hour: '2-digit',
                                  minute: '2-digit',
                                })}
                                {b.timezone ? ` · ${b.timezone}` : ''}
                              </span>
                              {isLive(b) ? (
                                <Badge tone="brand">{t('bookingsPage.liveNow')}</Badge>
                              ) : null}
                            </div>
                          </td>
                          <td className="px-4 py-3 align-top">
                            <div className="font-semibold text-text-light dark:text-text-dark">{venueName}</div>
                            <div className="mt-0.5 text-xs text-muted-light dark:text-muted-dark">
                              {resourceLabel(resources, b.resource_id)}
                            </div>
                          </td>
                          <td className="px-4 py-3 align-top">
                            <div className="flex items-start gap-2">
                              <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-500/15 text-xs font-bold text-brand-700 dark:text-brand-200">
                                {(guest?.displayName ?? '?')[0]?.toUpperCase()}
                              </div>
                              <div className="min-w-0">
                                <div className="truncate font-semibold">
                                  {guest?.loading ? t('common.loading') : guest?.displayName}
                                </div>
                                {guest?.email ? (
                                  <div className="truncate text-xs text-muted-light dark:text-muted-dark">
                                    {guest.email}
                                  </div>
                                ) : null}
                              </div>
                            </div>
                          </td>
                          <td className="px-4 py-3 align-top">
                            <Badge tone={bookingBadgeTone(b.status)}>
                              {localizedBookingStatus(t, b.status)}
                            </Badge>
                          </td>
                          <td className="px-4 py-3 align-top">
                            <Badge tone={paymentBadgeTone(b.payment_status)}>
                              {localizedPaymentStatus(t, b.payment_status)}
                            </Badge>
                          </td>
                          <td className="px-4 py-3 align-top text-right font-bold text-brand-700 dark:text-brand-300">
                            {formatPrice(
                              typeof b.price_total === 'string'
                                ? Number.parseInt(b.price_total, 10)
                                : Number(b.price_total),
                              b.currency ?? 'KZT',
                            )}
                          </td>
                          <td className="px-4 py-3 align-top">
                            <button
                              type="button"
                              onClick={() => setDetail(b)}
                              className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-muted-light hover:bg-black/5 hover:text-text-light dark:text-muted-dark dark:hover:bg-white/10"
                              aria-label={t('bookingsPage.openDetails')}
                            >
                              <ChevronRight size={18} />
                            </button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              <div className="xl:hidden space-y-3">
                {flatBookings.map((b) => {
                  const guest = guestById[b.user_id];
                  const venueName = venueNameById.get(b.venue_id) ?? b.venue_id;
                  return (
                    <button
                      key={b.id}
                      type="button"
                      onClick={() => setDetail(b)}
                      className={cn(
                        'w-full rounded-xl border border-black/5 bg-surface-light p-4 text-left shadow-sm transition-colors',
                        'dark:border-white/10 dark:bg-surface-dark hover:border-brand-500/40',
                      )}
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <div className="text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
                            {formatInTimezone(b.start_at, b.timezone, i18n.language, {
                              weekday: 'short',
                              day: 'numeric',
                              month: 'short',
                            })}
                          </div>
                          <div className="mt-1 text-sm font-extrabold text-text-light dark:text-text-dark">
                            {formatInTimezone(b.start_at, b.timezone, i18n.language, {
                              hour: '2-digit',
                              minute: '2-digit',
                            })}{' '}
                            –{' '}
                            {formatInTimezone(b.end_at, b.timezone, i18n.language, {
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </div>
                          <div className="mt-2 flex flex-wrap gap-2">
                            <Badge tone={bookingBadgeTone(b.status)}>
                              {localizedBookingStatus(t, b.status)}
                            </Badge>
                            <Badge tone={paymentBadgeTone(b.payment_status)}>
                              {localizedPaymentStatus(t, b.payment_status)}
                            </Badge>
                            {isLive(b) ? <Badge tone="brand">{t('bookingsPage.liveNow')}</Badge> : null}
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="text-sm font-bold text-brand-700 dark:text-brand-300">
                            {formatPrice(
                              typeof b.price_total === 'string'
                                ? Number.parseInt(b.price_total, 10)
                                : Number(b.price_total),
                              b.currency ?? 'KZT',
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="mt-3 flex items-center gap-2 text-sm text-muted-light dark:text-muted-dark">
                        <MapPin size={14} className="shrink-0" />
                        <span className="truncate">
                          {venueName} · {resourceLabel(resources, b.resource_id)}
                        </span>
                      </div>
                      <div className="mt-1 flex items-center gap-2 text-sm font-semibold text-text-light dark:text-text-dark">
                        <UserRound size={14} className="shrink-0 text-muted-light dark:text-muted-dark" />
                        <span className="truncate">
                          {guest?.loading ? t('common.loading') : guest?.displayName}
                        </span>
                      </div>
                    </button>
                  );
                })}
              </div>

              {hasNextPage ? (
                <div className="mt-6 flex justify-center">
                  <Button
                    type="button"
                    variant="secondary"
                    onClick={() => infinite.fetchNextPage()}
                    disabled={infinite.isFetchingNextPage}
                    leftIcon={
                      infinite.isFetchingNextPage ? <Loader2 size={16} className="animate-spin" /> : undefined
                    }
                  >
                    {t('bookingsPage.loadMore')}
                  </Button>
                </div>
              ) : null}
            </>
          )}
        </CardBody>
      </Card>

      <Modal
        open={!!detail}
        onClose={() => setDetail(null)}
        title={t('bookingsPage.detailTitle')}
        description={detail?.id}
        size="lg"
        maxHeight="min(85vh, 720px)"
        footer={
          detail && detail.status?.toLowerCase() !== 'cancelled' ? (
            <Button type="button" variant="danger" size="sm" onClick={() => setCancelTarget(detail)}>
              {t('bookingsPage.cancelBooking')}
            </Button>
          ) : undefined
        }
      >
        {detail ? (
          <BookingDetailBody
            booking={detail}
            venueName={venueNameById.get(detail.venue_id) ?? detail.venue_id}
            resourceName={resourceLabel(detailResources, detail.resource_id)}
            guest={guestById[detail.user_id]}
            locale={i18n.language}
            t={t}
            onCopy={copyText}
            isLive={isLive(detail)}
          />
        ) : null}
      </Modal>

      <ConfirmDialog
        open={!!cancelTarget}
        onClose={() => setCancelTarget(null)}
        onConfirm={() => {
          if (!cancelTarget) return;
          const id = cancelTarget.id;
          void cancelMut
            .mutateAsync({ id, reason: 'owner_cancelled' })
            .then(() => {
              setDetail(null);
              infinite.refetch();
            });
        }}
        title={t('bookingsPage.cancelConfirmTitle')}
        description={t('bookingsPage.cancelConfirmBody')}
        confirmLabel={t('bookingsPage.cancelBooking')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </div>
  );
}

function FilterSelect({
  label,
  value,
  onChange,
  disabled,
  children,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  disabled?: boolean;
  children: ReactNode;
}) {
  return (
    <label className="flex flex-col gap-1 text-[11px] font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
      {label}
      <select
        disabled={disabled}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={cn(
          'h-10 min-w-[180px] rounded-lg border border-black/10 bg-surface-light px-3 text-sm font-semibold text-text-light',
          'dark:border-white/10 dark:bg-surface-dark dark:text-text-dark',
          disabled ? 'cursor-not-allowed opacity-50' : '',
        )}
      >
        {children}
      </select>
    </label>
  );
}

function resourceLabel(resources: { id: string; name?: string }[], resourceId: string): string {
  const hit = resources.find((r) => r.id === resourceId);
  return hit?.name ?? resourceId;
}

function BookingDetailBody({
  booking,
  venueName,
  resourceName,
  guest,
  locale,
  t,
  onCopy,
  isLive,
}: {
  booking: ApiBooking;
  venueName: string;
  resourceName: string;
  guest?: { displayName: string; email?: string; loading: boolean };
  locale: string;
  t: TFunction;
  onCopy: (label: string, value: string) => void;
  isLive: boolean;
}) {
  const priceNum =
    typeof booking.price_total === 'string'
      ? Number.parseInt(booking.price_total, 10)
      : Number(booking.price_total);

  return (
    <div className="space-y-6">
      <section className="rounded-xl border border-black/5 bg-black/[0.02] p-4 dark:border-white/10 dark:bg-white/[0.04]">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
          <CalendarClock size={14} />
          {t('bookingsPage.sectionSchedule')}
        </div>
        <div className="mt-2 text-lg font-extrabold text-text-light dark:text-text-dark">
          {formatInTimezone(booking.start_at, booking.timezone, locale, {
            weekday: 'long',
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          })}
        </div>
        <div className="mt-1 text-sm font-semibold text-muted-light dark:text-muted-dark">
          {formatInTimezone(booking.start_at, booking.timezone, locale, {
            hour: '2-digit',
            minute: '2-digit',
          })}{' '}
          –{' '}
          {formatInTimezone(booking.end_at, booking.timezone, locale, {
            hour: '2-digit',
            minute: '2-digit',
          })}
          {booking.timezone ? ` · ${booking.timezone}` : ''}
        </div>
        {isLive ? (
          <div className="mt-3">
            <Badge tone="brand">{t('bookingsPage.liveNow')}</Badge>
          </div>
        ) : null}
      </section>

      <section className="rounded-xl border border-black/5 p-4 dark:border-white/10">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
          <MapPin size={14} />
          {t('bookingsPage.sectionFacility')}
        </div>
        <div className="mt-2 font-bold text-text-light dark:text-text-dark">{venueName}</div>
        <div className="text-sm text-muted-light dark:text-muted-dark">{resourceName}</div>
      </section>

      <section className="rounded-xl border border-black/5 p-4 dark:border-white/10">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
          <UserRound size={14} />
          {t('bookingsPage.sectionGuest')}
        </div>
        <div className="mt-2 text-lg font-bold text-text-light dark:text-text-dark">
          {guest?.loading ? t('common.loading') : guest?.displayName}
        </div>
        {guest?.email ? <div className="text-sm text-muted-light dark:text-muted-dark">{guest.email}</div> : null}
        <div className="mt-3 flex flex-wrap items-center gap-2">
          <code className="rounded-md bg-black/5 px-2 py-1 text-xs dark:bg-white/10">{booking.user_id}</code>
          <button
            type="button"
            className="inline-flex items-center gap-1 rounded-lg px-2 py-1 text-xs font-semibold text-brand-600 hover:bg-brand-500/10 dark:text-brand-300"
            onClick={() => onCopy('user id', booking.user_id)}
          >
            <Copy size={12} />
            {t('bookingsPage.copyId')}
          </button>
        </div>
      </section>

      <section className="rounded-xl border border-black/5 p-4 dark:border-white/10">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
          <Wallet size={14} />
          {t('bookingsPage.sectionPayment')}
        </div>
        <div className="mt-3 flex flex-wrap gap-2">
          <Badge tone="neutral">{localizedBookingStatus(t, booking.status)}</Badge>
          <Badge tone="neutral">{localizedPaymentStatus(t, booking.payment_status)}</Badge>
        </div>
        <div className="mt-3 text-2xl font-extrabold text-brand-700 dark:text-brand-300">
          {formatPrice(priceNum, booking.currency ?? 'KZT')}
        </div>
        {booking.payment_intent_id ? (
          <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-muted-light dark:text-muted-dark">
            <span>{t('bookingsPage.paymentIntent')}</span>
            <code className="rounded bg-black/5 px-1.5 py-0.5 dark:bg-white/10">{booking.payment_intent_id}</code>
            <button
              type="button"
              className="inline-flex items-center gap-1 font-semibold text-brand-600 dark:text-brand-300"
              onClick={() => onCopy('payment intent', booking.payment_intent_id!)}
            >
              <Copy size={12} />
            </button>
          </div>
        ) : null}
      </section>

      <section className="rounded-xl border border-black/5 p-4 text-sm dark:border-white/10">
        <div className="text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
          {t('bookingsPage.sectionTimeline')}
        </div>
        <ul className="mt-3 space-y-2 text-muted-light dark:text-muted-dark">
          <li>
            <span className="font-semibold text-text-light dark:text-text-dark">{t('bookingsPage.tlCreated')}</span>{' '}
            {formatTs(booking.created_at, locale)}
          </li>
          <li>
            <span className="font-semibold text-text-light dark:text-text-dark">{t('bookingsPage.tlHold')}</span>{' '}
            {formatTs(booking.hold_expires_at, locale)}
          </li>
          <li>
            <span className="font-semibold text-text-light dark:text-text-dark">{t('bookingsPage.tlConfirmed')}</span>{' '}
            {formatTs(booking.confirmed_at, locale)}
          </li>
          <li>
            <span className="font-semibold text-text-light dark:text-text-dark">{t('bookingsPage.tlCancelled')}</span>{' '}
            {formatTs(booking.cancelled_at, locale)}
            {booking.cancel_reason ? (
              <span className="block text-xs">
                {localizedCancelReason(t, booking.cancel_reason)}
              </span>
            ) : null}
          </li>
        </ul>
      </section>
    </div>
  );
}

function formatTs(iso: string | null | undefined, locale: string): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return new Intl.DateTimeFormat(locale, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(d);
}
