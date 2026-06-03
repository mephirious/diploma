import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  CalendarClock,
  ChevronRight,
  Copy,
  Loader2,
  MapPin,
  Plus,
  UserRound,
  Users,
} from 'lucide-react';

import { PageHeader } from '@/components/common/PageHeader';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Tabs } from '@/components/ui/Tabs';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Input, Select, Textarea } from '@/components/ui/Input';

import { useMyVenues, useVenueResources } from '@/hooks/useVenues';
import { useQueries } from '@tanstack/react-query';
import { venueApi } from '@/api/venues';
import {
  useCancelSession,
  useCreateOwnerSession,
  useOwnerSessionsForVenues,
  useParticipantDirectory,
  useSessionParticipants,
} from '@/hooks/useSessions';
import { formatInTimezone, formatPrice } from '@/lib/format';
import type { OwnerSessionCreatePayload, SessionInstance } from '@/types/session';
import type { Resource } from '@/types/resource';
import { cn } from '@/lib/cn';

type TimeTab = 'upcoming' | 'past';

function sessionBadgeTone(status: string): 'success' | 'warning' | 'info' | 'danger' | 'neutral' {
  const s = status.toLowerCase();
  if (s === 'open') return 'warning';
  if (s === 'locked' || s === 'active') return 'success';
  if (s === 'completed') return 'info';
  if (s === 'cancelled') return 'danger';
  return 'neutral';
}

function participantPaymentStatus(raw: string) {
  const normalized = raw.toLowerCase().trim().replaceAll(' ', '_').replace(/^payment_/, '');
  switch (normalized) {
    case 'held':
    case 'hold':
      return { key: 'held', tone: 'warning' as const };
    case 'charged':
    case 'paid':
    case 'succeeded':
      return { key: 'charged', tone: 'success' as const };
    case 'failed':
      return { key: 'failed', tone: 'danger' as const };
    case 'refunded':
      return { key: 'refunded', tone: 'info' as const };
    case 'pending':
    default:
      return { key: 'pending', tone: 'neutral' as const };
  }
}

export function SessionsPage() {
  const { t, i18n } = useTranslation();
  const [tab, setTab] = useState<TimeTab>('upcoming');
  const [venueFilter, setVenueFilter] = useState('');
  const [resourceFilter, setResourceFilter] = useState('');
  const [detail, setDetail] = useState<SessionInstance | null>(null);
  const [cancelTarget, setCancelTarget] = useState<SessionInstance | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [createVenueId, setCreateVenueId] = useState('');

  const cancelMut = useCancelSession();
  const createSession = useCreateOwnerSession(createVenueId);
  const { data: venueData } = useMyVenues();
  const venues = venueData?.results ?? [];

  const venueIds = useMemo(() => {
    if (venueFilter) return [venueFilter];
    return venues.map((v: { id: string }) => v.id).filter(Boolean);
  }, [venueFilter, venues]);

  const venueNameById = useMemo(() => {
    const m = new Map<string, string>();
    for (const v of venues as { id: string; name?: string }[]) {
      m.set(v.id, v.name ?? v.id);
    }
    return m;
  }, [venues]);

  const { items: sessions, isLoading } = useOwnerSessionsForVenues(venueIds, {
    timeframe: tab,
    resource_id: resourceFilter || undefined,
    page_size: 100,
  });

  const { data: resourcesData } = useVenueResources(venueFilter);
  const filteredResources = resourcesData?.results ?? [];
  const resources = filteredResources;
  const { data: createResourcesData } = useVenueResources(createVenueId);
  const createResources = (createResourcesData?.results ?? []) as Resource[];

  const sessionVenueIds = useMemo(
    () => [...new Set(sessions.map((s) => s.venue_id))],
    [sessions],
  );
  const resourceQueries = useQueries({
    queries: sessionVenueIds.map((vid) => ({
      queryKey: ['venues', vid, 'resources'],
      queryFn: () => venueApi.resources.list(vid),
      staleTime: 120_000,
    })),
  });

  const resourceNameById = useMemo(() => {
    const m = new Map<string, string>();
    for (const r of filteredResources as { id: string; name?: string }[]) {
      m.set(r.id, r.name ?? r.id);
    }
    for (const q of resourceQueries) {
      for (const r of (q.data?.results ?? []) as { id: string; name?: string }[]) {
        m.set(r.id, r.name ?? r.id);
      }
    }
    return m;
  }, [filteredResources, resourceQueries]);

  const { data: participantsData, isLoading: participantsLoading } = useSessionParticipants(
    detail?.id ?? null,
  );

  const participantUserIds = useMemo(
    () => participantsData?.participants?.map((p) => p.user_id) ?? [],
    [participantsData],
  );
  const { byId: userById } = useParticipantDirectory(participantUserIds);

  const detailResourceName =
    detail && resourceNameById.get(detail.resource_id)
      ? resourceNameById.get(detail.resource_id)!
      : detail?.resource_id ?? '';

  async function copyText(value: string) {
    try {
      await navigator.clipboard.writeText(value);
    } catch {
      window.prompt('Copy', value);
    }
  }

  return (
    <div>
      <PageHeader
        title={t('sessions.title')}
        subtitle={t('sessions.subtitle')}
        actions={
          <div className="flex flex-wrap items-center gap-2">
            <Button
              type="button"
              leftIcon={<Plus size={16} />}
              onClick={() => {
                setCreateVenueId(venueFilter || venues[0]?.id || '');
                setCreateOpen(true);
              }}
              disabled={venues.length === 0}
            >
              {t('sessions.createOneOff')}
            </Button>
            <Tabs<TimeTab>
              items={[
                { id: 'upcoming', label: t('sessions.upcoming') },
                { id: 'past', label: t('sessions.past') },
              ]}
              value={tab}
              onChange={setTab}
            />
          </div>
        }
      />

      <div className="mb-4 flex flex-wrap gap-3">
        <select
          className="rounded-lg border border-black/10 bg-surface-light px-3 py-2 text-sm font-semibold dark:border-white/10 dark:bg-surface-dark"
          value={venueFilter}
          onChange={(e) => {
            setVenueFilter(e.currentTarget.value);
            setResourceFilter('');
          }}
        >
          <option value="">{t('sessions.allVenues')}</option>
          {venues.map((v: { id: string; name?: string }) => (
            <option key={v.id} value={v.id}>
              {v.name ?? v.id}
            </option>
          ))}
        </select>
        {venueFilter ? (
          <select
            className="rounded-lg border border-black/10 bg-surface-light px-3 py-2 text-sm font-semibold dark:border-white/10 dark:bg-surface-dark"
            value={resourceFilter}
            onChange={(e) => setResourceFilter(e.currentTarget.value)}
          >
            <option value="">{t('sessions.allResources')}</option>
            {resources.map((r: { id: string; name?: string }) => (
              <option key={r.id} value={r.id}>
                {r.name ?? r.id}
              </option>
            ))}
          </select>
        ) : null}
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-16 text-muted-light dark:text-muted-dark">
          <Loader2 className="mr-2 animate-spin" size={18} />
          {t('common.loading')}
        </div>
      ) : sessions.length === 0 ? (
        <EmptyState
          icon={<CalendarClock size={22} />}
          title={t('sessions.emptyTitle')}
          description={t('sessions.emptyHint')}
        />
      ) : (
        <div className="space-y-3">
          {sessions.map((s) => (
            <SessionRow
              key={s.id}
              session={s}
              venueName={venueNameById.get(s.venue_id) ?? s.venue_id}
              resourceName={resourceNameById.get(s.resource_id) ?? s.resource_id.slice(0, 8)}
              locale={i18n.language}
              onOpen={() => setDetail(s)}
            />
          ))}
        </div>
      )}

      <Modal
        open={!!detail}
        onClose={() => setDetail(null)}
        title={detail?.name ?? t('sessions.title')}
        footer={
          detail && ['open', 'locked', 'active'].includes(detail.status) ? (
            <Button variant="danger" onClick={() => setCancelTarget(detail)}>
              {t('sessions.cancelSession')}
            </Button>
          ) : null
        }
      >
        {detail ? (
          <div className="space-y-4">
            <div className="flex flex-wrap gap-2">
              <Badge tone={sessionBadgeTone(detail.status)}>
                {t(`sessions.status.${detail.status}`)}
              </Badge>
              <Badge tone="neutral">{t(`sessions.mode.${detail.mode}`)}</Badge>
              <Badge tone="info">
                {detail.participant_count}/{detail.max_participants} {t('sessions.players')}
              </Badge>
            </div>

            <dl className="grid gap-3 text-sm sm:grid-cols-2">
              <DetailItem
                icon={<MapPin size={14} />}
                label={t('sessions.venue')}
                value={venueNameById.get(detail.venue_id) ?? detail.venue_id}
              />
              <DetailItem
                icon={<CalendarClock size={14} />}
                label={t('resource.name')}
                value={detailResourceName}
              />
              <DetailItem
                icon={<CalendarClock size={14} />}
                label={t('sessions.startsAt')}
                value={formatInTimezone(detail.starts_at, detail.timezone, i18n.language, {
                  dateStyle: 'medium',
                  timeStyle: 'short',
                })}
              />
              <DetailItem
                icon={<CalendarClock size={14} />}
                label={t('sessions.endsAt')}
                value={formatInTimezone(detail.ends_at, detail.timezone, i18n.language, {
                  dateStyle: 'medium',
                  timeStyle: 'short',
                })}
              />
              <DetailItem
                icon={<Users size={14} />}
                label={t('sessions.pricing')}
                value={
                  detail.pricing_model === 'fixed_split' && detail.price_total_minor != null
                    ? `${t('sessions.fixedSplit')}: ${formatPrice(detail.price_total_minor, detail.currency)}`
                    : detail.price_per_person_minor != null
                      ? `${formatPrice(detail.price_per_person_minor, detail.currency)} / ${t('sessions.person')}`
                      : '—'
                }
              />
              {detail.invite_code ? (
                <DetailItem
                  icon={<Copy size={14} />}
                  label={t('sessions.inviteCode')}
                  value={
                    <button
                      type="button"
                      className="font-mono text-xs underline"
                      onClick={() => void copyText(detail.invite_code!)}
                    >
                      {detail.invite_code}
                    </button>
                  }
                />
              ) : null}
            </dl>

            <Card>
              <CardHeader>
                <h4 className="text-sm font-extrabold">{t('sessions.participants')}</h4>
              </CardHeader>
              <CardBody>
                {participantsLoading ? (
                  <div className="flex items-center gap-2 text-sm text-muted-light dark:text-muted-dark">
                    <Loader2 size={14} className="animate-spin" />
                    {t('common.loading')}
                  </div>
                ) : !participantsData?.participants?.length ? (
                  <p className="text-sm text-muted-light dark:text-muted-dark">
                    {t('sessions.noParticipants')}
                  </p>
                ) : (
                  <ul className="space-y-2">
                    {participantsData.participants.map((p) => (
                      <li
                        key={p.id}
                        className="flex items-center justify-between rounded-md bg-black/[0.03] px-3 py-2 text-sm dark:bg-white/[0.04]"
                      >
                        <div className="flex items-center gap-2">
                          <UserRound size={14} className="text-muted-light dark:text-muted-dark" />
                          <div>
                            <div className="font-semibold">
                              {userById[p.user_id]?.displayName ?? p.user_id.slice(0, 8)}
                            </div>
                            {userById[p.user_id]?.email ? (
                              <div className="text-xs text-muted-light dark:text-muted-dark">
                                {userById[p.user_id]?.email}
                              </div>
                            ) : null}
                          </div>
                        </div>
                        <div className="text-right text-xs">
                          <div>{formatPrice(p.final_price_minor ?? p.quoted_price_minor, p.currency)}</div>
                          <Badge tone={participantPaymentStatus(p.payment_status).tone}>
                            {t(`sessions.paymentStatus.${participantPaymentStatus(p.payment_status).key}`)}
                          </Badge>
                        </div>
                      </li>
                    ))}
                  </ul>
                )}
              </CardBody>
            </Card>

            <Link
              to={`/facilities/${detail.venue_id}/resources/${detail.resource_id}`}
              className="inline-flex items-center gap-1 text-sm font-semibold text-brand-600 dark:text-brand-300"
              onClick={() => setDetail(null)}
            >
              {t('sessions.openResource')} <ChevronRight size={14} />
            </Link>
          </div>
        ) : null}
      </Modal>

      <ConfirmDialog
        open={!!cancelTarget}
        onClose={() => setCancelTarget(null)}
        onConfirm={async () => {
          if (!cancelTarget) return;
          await cancelMut.mutateAsync(cancelTarget.id);
          setCancelTarget(null);
          setDetail(null);
        }}
        title={t('sessions.cancelConfirmTitle')}
        description={t('sessions.cancelConfirmBody')}
        confirmLabel={t('sessions.cancelSession')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />

      <OwnerSessionCreateModal
        open={createOpen}
        venues={venues as { id: string; name?: string; sports?: string[] }[]}
        venueId={createVenueId}
        resources={createResources}
        saving={createSession.isPending}
        onVenueChange={setCreateVenueId}
        onClose={() => setCreateOpen(false)}
        onSave={async (payload) => {
          await createSession.mutateAsync(payload);
          setCreateOpen(false);
        }}
      />
    </div>
  );
}

function SessionRow({
  session: s,
  venueName,
  resourceName,
  locale,
  onOpen,
}: {
  session: SessionInstance;
  venueName: string;
  resourceName: string;
  locale: string;
  onOpen: () => void;
}) {
  const { t } = useTranslation();
  const live =
    Date.now() >= new Date(s.starts_at).getTime() &&
    Date.now() <= new Date(s.ends_at).getTime() &&
    !['cancelled', 'completed'].includes(s.status);

  return (
    <button
      type="button"
      onClick={onOpen}
      className={cn(
        'flex w-full items-center gap-4 rounded-xl border px-4 py-3 text-left transition-colors',
        'border-black/5 bg-surface-light hover:bg-black/[0.02]',
        'dark:border-white/10 dark:bg-surface-dark dark:hover:bg-white/[0.04]',
        live && 'ring-1 ring-brand-500/40',
      )}
    >
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className="font-extrabold text-text-light dark:text-text-dark">{s.name}</span>
          <Badge tone={sessionBadgeTone(s.status)}>{t(`sessions.status.${s.status}`)}</Badge>
          {live ? <Badge tone="success">{t('sessions.live')}</Badge> : null}
        </div>
        <div className="mt-1 text-sm text-muted-light dark:text-muted-dark">
          {formatInTimezone(s.starts_at, s.timezone, locale, {
            weekday: 'short',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
          })}
          {' · '}
          {venueName} · {resourceName}
        </div>
        <div className="mt-0.5 text-xs text-muted-light dark:text-muted-dark">
          {s.participant_count}/{s.max_participants} {t('sessions.players')}
          {' · '}
          {t(`sessions.mode.${s.mode}`)}
        </div>
      </div>
      <ChevronRight size={16} className="shrink-0 text-muted-light dark:text-muted-dark" />
    </button>
  );
}

function OwnerSessionCreateModal({
  open,
  venues,
  venueId,
  resources,
  saving,
  onVenueChange,
  onClose,
  onSave,
}: {
  open: boolean;
  venues: { id: string; name?: string; sports?: string[] }[];
  venueId: string;
  resources: Resource[];
  saving: boolean;
  onVenueChange: (venueId: string) => void;
  onClose: () => void;
  onSave: (payload: OwnerSessionCreatePayload) => Promise<void>;
}) {
  const { t } = useTranslation();
  const [resourceId, setResourceId] = useState('');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [mode, setMode] = useState<'scheduled' | 'open'>('scheduled');
  const [startsAt, setStartsAt] = useState('');
  const [endsAt, setEndsAt] = useState('');
  const [timezone, setTimezone] = useState('Asia/Almaty');
  const [minParticipants, setMinParticipants] = useState('4');
  const [maxParticipants, setMaxParticipants] = useState('10');
  const [pricingModel, setPricingModel] = useState<'fixed_split' | 'per_person'>('fixed_split');
  const [priceTotal, setPriceTotal] = useState('20000');
  const [pricePerPerson, setPricePerPerson] = useState('2000');
  const [currency, setCurrency] = useState('KZT');
  const [lockBefore, setLockBefore] = useState('60');
  const [visibility, setVisibility] = useState<'public' | 'link_only' | 'private'>('public');
  const [error, setError] = useState('');

  const selectedResource = resources.find((r) => r.id === resourceId);
  const selectedVenue = venues.find((v) => v.id === venueId);
  const sport = selectedResource?.sport || selectedVenue?.sports?.[0] || 'other';

  useEffect(() => {
    if (!open) return;
    setResourceId('');
    setName('');
    setDescription('');
    setMode('scheduled');
    setStartsAt('');
    setEndsAt('');
    setTimezone('Asia/Almaty');
    setMinParticipants('4');
    setMaxParticipants('10');
    setPricingModel('fixed_split');
    setPriceTotal('20000');
    setPricePerPerson('2000');
    setCurrency('KZT');
    setLockBefore('60');
    setVisibility('public');
    setError('');
  }, [open]);

  useEffect(() => {
    setResourceId('');
  }, [venueId]);

  function save() {
    setError('');
    if (!venueId || !resourceId || !name.trim() || !startsAt || !endsAt) {
      setError(t('sessions.createRequired'));
      return;
    }
    const starts = new Date(startsAt);
    const ends = new Date(endsAt);
    if (Number.isNaN(starts.getTime()) || Number.isNaN(ends.getTime()) || !ends.getTime() || ends <= starts) {
      setError(t('sessions.createInvalidTime'));
      return;
    }

    const min = Number(minParticipants) || (mode === 'open' ? 1 : 2);
    const max = Number(maxParticipants) || min;
    const lock = Number(lockBefore);
    const effectivePricingModel = mode === 'open' ? 'per_person' : pricingModel;
    void onSave({
      resource_id: resourceId,
      name: name.trim(),
      description: description.trim() || undefined,
      mode,
      sport,
      starts_at: starts.toISOString(),
      ends_at: ends.toISOString(),
      timezone: timezone.trim() || 'Asia/Almaty',
      min_participants: min,
      max_participants: max,
      pricing_model: effectivePricingModel,
      price_total_minor:
        effectivePricingModel === 'fixed_split' ? Number(priceTotal) || undefined : undefined,
      price_per_person_minor:
        effectivePricingModel === 'per_person' ? Number(pricePerPerson) || undefined : undefined,
      currency: currency.trim() || 'KZT',
      lock_before_minutes: Number.isFinite(lock) && lock >= 0 ? lock : 60,
      visibility,
    }).catch((e) => setError(e?.message ?? t('sessions.createError')));
  }

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('sessions.createOneOff')}
      size="lg"
      maxHeight="min(85vh, 760px)"
      footer={
        <>
          <Button type="button" variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button type="button" loading={saving} onClick={save}>
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Select
          label={t('sessions.venue')}
          value={venueId}
          onChange={(e) => onVenueChange(e.currentTarget.value)}
          options={[
            { value: '', label: t('sessions.chooseVenue') },
            ...venues.map((v) => ({ value: v.id, label: v.name ?? v.id })),
          ]}
        />
        <Select
          label={t('resource.name')}
          value={resourceId}
          onChange={(e) => setResourceId(e.currentTarget.value)}
          options={[
            { value: '', label: t('sessions.chooseResource') },
            ...resources.map((r) => ({ value: r.id, label: r.name ?? r.id })),
          ]}
        />
        <Input label={t('sessions.ruleName')} value={name} onChange={(e) => setName(e.currentTarget.value)} />
        <Select
          label={t('sessions.modeLabel')}
          value={mode}
          onChange={(e) => {
            const next = e.currentTarget.value as 'scheduled' | 'open';
            setMode(next);
            if (next === 'open') {
              setPricingModel('per_person');
              setMinParticipants('1');
            }
          }}
          options={[
            { value: 'scheduled', label: t('sessions.mode.scheduled') },
            { value: 'open', label: t('sessions.mode.open') },
          ]}
        />
        <Input label={t('sessions.startsAt')} type="datetime-local" value={startsAt} onChange={(e) => setStartsAt(e.currentTarget.value)} />
        <Input label={t('sessions.endsAt')} type="datetime-local" value={endsAt} onChange={(e) => setEndsAt(e.currentTarget.value)} />
        <Input label={t('sessions.timezone')} value={timezone} onChange={(e) => setTimezone(e.currentTarget.value)} />
        <Input label={t('sessions.lockBefore')} type="number" min={0} value={lockBefore} onChange={(e) => setLockBefore(e.currentTarget.value)} />
        <Input label={t('sessions.minPlayers')} type="number" min={1} value={minParticipants} onChange={(e) => setMinParticipants(e.currentTarget.value)} />
        <Input label={t('sessions.maxPlayers')} type="number" min={1} value={maxParticipants} onChange={(e) => setMaxParticipants(e.currentTarget.value)} />
        <Select
          label={t('sessions.pricingModel')}
          value={mode === 'open' ? 'per_person' : pricingModel}
          disabled={mode === 'open'}
          onChange={(e) => setPricingModel(e.currentTarget.value as 'fixed_split' | 'per_person')}
          options={[
            { value: 'fixed_split', label: t('sessions.fixedSplit') },
            { value: 'per_person', label: t('sessions.perPerson') },
          ]}
        />
        {mode !== 'open' && pricingModel === 'fixed_split' ? (
          <Input label={t('sessions.totalPrice')} type="number" min={1} value={priceTotal} onChange={(e) => setPriceTotal(e.currentTarget.value)} />
        ) : (
          <Input label={t('sessions.pricePerPerson')} type="number" min={1} value={pricePerPerson} onChange={(e) => setPricePerPerson(e.currentTarget.value)} />
        )}
        <Input label={t('sessions.currency')} value={currency} onChange={(e) => setCurrency(e.currentTarget.value)} />
        <Select
          label={t('sessions.visibilityLabel')}
          value={visibility}
          onChange={(e) => setVisibility(e.currentTarget.value as typeof visibility)}
          options={[
            { value: 'public', label: t('sessions.visibility.public') },
            { value: 'link_only', label: t('sessions.visibility.link_only') },
            { value: 'private', label: t('sessions.visibility.private') },
          ]}
        />
        <Textarea
          className="md:col-span-2"
          label={t('facilityDetail.description')}
          rows={3}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
        />
        {error ? (
          <div className="md:col-span-2 rounded-lg border border-danger/30 bg-danger/10 px-3 py-2 text-sm font-semibold text-danger">
            {error}
          </div>
        ) : null}
      </div>
    </Modal>
  );
}

function DetailItem({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: React.ReactNode;
}) {
  return (
    <div>
      <dt className="flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
        {icon}
        {label}
      </dt>
      <dd className="mt-0.5 font-semibold text-text-light dark:text-text-dark">{value}</dd>
    </div>
  );
}
