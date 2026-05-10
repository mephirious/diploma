import { useMemo, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  ArrowLeft,
  Phone,
  Mail,
  Link as LinkIcon,
  MapPin,
  Clock,
  Pencil,
  Trash2,
  Plus,
  Globe,
  Users,
  Settings2,
  ChevronRight,
} from 'lucide-react';

import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Tabs } from '@/components/ui/Tabs';
import { PageHeader } from '@/components/common/PageHeader';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { StatusChip } from '@/components/common/StatusChip';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { IconButton } from '@/components/ui/IconButton';

import { MOCK_VENUES } from '@/mock/venues';
import { getScheduleResult } from '@/mock/scheduleResults';
import { buildAddress, shortTime } from '@/lib/format';
import type { Venue, VenueContact } from '@/types/venue';
import type { Resource } from '@/types/resource';

const RESOURCE_TYPE_ICONS: Record<string, React.ReactNode> = {
  court: <span className="text-lg">🎾</span>,
  field: <span className="text-lg">⚽</span>,
  lane: <span className="text-lg">🏊</span>,
  table: <span className="text-lg">🏓</span>,
  hall: <span className="text-lg">🏛️</span>,
  other: <span className="text-lg">📐</span>,
};

type Tab = 'overview' | 'resources';

export function FacilityDetailPage() {
  const { t } = useTranslation();
  const { facilityId = '' } = useParams();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('overview');
  const [activeImage, setActiveImage] = useState(0);
  const [confirmOpen, setConfirmOpen] = useState(false);

  const venue = useMemo<Venue | undefined>(
    () => MOCK_VENUES.find((v) => v.id === facilityId),
    [facilityId],
  );
  const result = useMemo(
    () => (venue ? getScheduleResult(venue.id) : null),
    [venue],
  );

  if (!venue || !result) {
    return (
      <EmptyState
        icon={<MapPin size={22} />}
        title={t('facilities.emptyTitle')}
        description={t('facilities.emptyHint')}
        action={
          <Link to="/facilities">
            <Button variant="outline" leftIcon={<ArrowLeft size={14} />}>
              {t('common.back')}
            </Button>
          </Link>
        }
      />
    );
  }

  return (
    <div>
      <Link
        to="/facilities"
        className="mb-4 inline-flex items-center gap-1.5 text-sm font-semibold text-muted-light hover:text-text-light dark:text-muted-dark dark:hover:text-text-dark"
      >
        <ArrowLeft size={16} /> {t('facilities.title')}
      </Link>

      <div className="grid gap-6 lg:grid-cols-[1.3fr_1fr]">
        <div>
          <div className="relative overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-surface-light dark:bg-surface-dark shadow-card">
            <div className="relative h-72 w-full overflow-hidden">
              <img
                src={venue.images[activeImage]}
                alt={venue.name}
                className="h-full w-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
              <div className="absolute top-4 left-4 flex items-center gap-2">
                <StatusChip status={venue.status} />
                <Badge tone="brand">{venue.timezone}</Badge>
              </div>
              <div className="absolute top-4 right-4 flex items-center gap-2">
                <Button variant="secondary" size="sm" leftIcon={<Pencil size={14} />}>
                  {t('common.edit')}
                </Button>
                <IconButton
                  icon={<Trash2 size={16} />}
                  aria-label={t('common.delete')}
                  tone="danger"
                  onClick={() => setConfirmOpen(true)}
                  className="bg-white/90 dark:bg-surface-dark/80"
                />
              </div>
              <div className="absolute left-4 bottom-4 right-4 text-white">
                <h1 className="text-2xl font-extrabold drop-shadow md:text-3xl">
                  {venue.name}
                </h1>
                <div className="mt-1.5 flex flex-wrap items-center gap-2">
                  {venue.sports.map((s) => (
                    <span
                      key={s}
                      className="rounded-full bg-white/20 px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide backdrop-blur"
                    >
                      {t(`sports.${s}`)}
                    </span>
                  ))}
                </div>
              </div>
            </div>
            {venue.images.length > 1 ? (
              <div className="flex gap-2 overflow-x-auto p-3">
                {venue.images.map((src, i) => (
                  <button
                    key={src}
                    type="button"
                    onClick={() => setActiveImage(i)}
                    className={`relative h-16 w-24 shrink-0 overflow-hidden rounded-md border transition-all ${
                      activeImage === i
                        ? 'border-brand-500 ring-2 ring-brand-500/40'
                        : 'border-black/5 dark:border-white/10 opacity-70 hover:opacity-100'
                    }`}
                  >
                    <img
                      src={src}
                      alt={`${venue.name} ${i + 1}`}
                      className="h-full w-full object-cover"
                    />
                  </button>
                ))}
              </div>
            ) : null}
          </div>

          <PageHeader
            title={<span className="sr-only">{venue.name}</span>}
            actions={
              <Tabs<Tab>
                items={[
                  { id: 'overview', label: t('facilityDetail.overview') },
                  { id: 'resources', label: `${t('facilityDetail.resources')} (${result.groups.length})` },
                ]}
                value={tab}
                onChange={setTab}
              />
            }
            className="mt-6"
          />

          {tab === 'overview' ? <OverviewTab venue={venue} /> : <ResourcesTab venue={venue} />}
        </div>

        <aside className="space-y-6 lg:sticky lg:top-20 self-start">
          <Card>
            <CardHeader>
              <h3 className="text-base font-extrabold">
                {t('facilityDetail.overview')}
              </h3>
            </CardHeader>
            <CardBody className="space-y-4">
              <InfoRow
                icon={<MapPin size={16} />}
                label={t('facilityDetail.location')}
              >
                {buildAddress(venue)}
              </InfoRow>
              <InfoRow
                icon={<Clock size={16} />}
                label={t('resource.weeklyTitle')}
              >
                {summarizeWeeklyHours(result.groups)}
              </InfoRow>
              <InfoRow
                icon={<Users size={16} />}
                label={t('facilityDetail.resources')}
              >
                {result.groups.length}
              </InfoRow>
            </CardBody>
          </Card>

          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3 className="text-base font-extrabold">
                  {t('facilityDetail.contacts')}
                </h3>
                <Button size="sm" variant="ghost" leftIcon={<Plus size={14} />}>
                  {t('facilityDetail.addContact')}
                </Button>
              </div>
            </CardHeader>
            <CardBody>
              {venue.contacts.length === 0 ? (
                <p className="text-sm text-muted-light dark:text-muted-dark">
                  {t('common.none')}
                </p>
              ) : (
                <ul className="space-y-3">
                  {venue.contacts.map((c, i) => (
                    <li key={i}>
                      <ContactRow contact={c} />
                    </li>
                  ))}
                </ul>
              )}
            </CardBody>
          </Card>
        </aside>
      </div>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={() => navigate('/facilities', { replace: true })}
        title={t('facilityDetail.deleteConfirm')}
        description={t('facilityDetail.deleteHint')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </div>
  );
}

function OverviewTab({ venue }: { venue: Venue }) {
  const { t } = useTranslation();
  return (
    <Card>
      <CardHeader>
        <h3 className="text-base font-extrabold">
          {t('facilityDetail.description')}
        </h3>
      </CardHeader>
      <CardBody className="space-y-6">
        <p className="text-[15px] leading-relaxed text-text-light dark:text-text-dark">
          {venue.description}
        </p>

        <div className="grid gap-3 sm:grid-cols-3">
          <MetaCard label="City">{venue.city}</MetaCard>
          <MetaCard label="Country">{venue.country}</MetaCard>
          <MetaCard label="Timezone">{venue.timezone}</MetaCard>
        </div>
      </CardBody>
    </Card>
  );
}

function ResourcesTab({ venue }: { venue: Venue }) {
  const { t } = useTranslation();
  const result = getScheduleResult(venue.id);

  if (result.groups.length === 0) {
    return (
      <EmptyState
        icon={<Settings2 size={22} />}
        title={t('facilityDetail.noResources')}
        description={t('facilityDetail.manageResources')}
        action={
          <Button leftIcon={<Plus size={16} />}>
            {t('facilityDetail.addResource')}
          </Button>
        }
      />
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <h3 className="text-base font-extrabold">
            {t('facilityDetail.manageResources')}
          </h3>
          <Button size="sm" leftIcon={<Plus size={14} />}>
            {t('facilityDetail.addResource')}
          </Button>
        </div>
      </CardHeader>
      <CardBody className="grid gap-4 lg:grid-cols-2">
        {result.groups.map((g) => (
          <ResourceCard
            key={g.resource_id}
            resource={g.resource}
            schedulesCount={g.schedules.length}
            pricingCount={g.pricing.length}
            venueId={venue.id}
          />
        ))}
      </CardBody>
    </Card>
  );
}

function ResourceCard({
  resource,
  venueId,
  schedulesCount,
  pricingCount,
}: {
  resource: Resource;
  venueId: string;
  schedulesCount: number;
  pricingCount: number;
}) {
  const { t } = useTranslation();
  const name = resource.name ?? `Resource ${resource.id}`;
  const typeKey = (resource.type ?? 'other') as keyof typeof RESOURCE_TYPE_ICONS;

  return (
    <Link
      to={`/facilities/${venueId}/resources/${resource.id}`}
      className="group relative overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-surface-light dark:bg-surface-dark shadow-card transition-all hover:shadow-card-hover"
    >
      <div className="relative h-32 overflow-hidden">
        <img
          src={resource.images[0] ?? 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=1200'}
          alt={name}
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
        <div className="absolute top-3 right-3">
          <StatusChip status={(resource.status ?? 'active') as 'active' | 'inactive' | 'maintenance'} />
        </div>
        <div className="absolute left-3 bottom-2 flex items-center gap-2 text-white">
          <span className="flex h-8 w-8 items-center justify-center rounded-full bg-white/20 backdrop-blur">
            {RESOURCE_TYPE_ICONS[typeKey] ?? RESOURCE_TYPE_ICONS.other}
          </span>
          <div>
            <div className="text-sm font-extrabold">{name}</div>
            <div className="text-[11px] uppercase tracking-widest opacity-90">
              {t(`facilityDetail.resourceTypes.${typeKey}`, { defaultValue: resource.type ?? 'Other' })}
            </div>
          </div>
        </div>
      </div>
      <div className="flex items-center justify-between gap-2 p-4">
        <div className="grid grid-cols-3 gap-2 text-center">
          <Metric label={t('resource.sport')} value={t(`sports.${resource.sport ?? 'other'}`, { defaultValue: '—' })} />
          <Metric label={t('resource.capacity')} value={resource.capacity != null ? String(resource.capacity) : '—'} />
          <Metric
            label={t('resource.slotsSchedules')}
            value={`${schedulesCount}·${pricingCount}`}
            hint={`${schedulesCount} schedule / ${pricingCount} pricing`}
          />
        </div>
        <ChevronRight
          size={18}
          className="text-muted-light transition-transform group-hover:translate-x-0.5 dark:text-muted-dark"
        />
      </div>
    </Link>
  );
}

function Metric({ label, value, hint }: { label: string; value: string; hint?: string }) {
  return (
    <div title={hint}>
      <div className="text-sm font-bold text-text-light dark:text-text-dark">{value}</div>
      <div className="text-[10px] uppercase tracking-widest text-muted-light dark:text-muted-dark">
        {label}
      </div>
    </div>
  );
}

function InfoRow({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex gap-3">
      <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-brand-500/10 text-brand-700 dark:text-brand-300">
        {icon}
      </span>
      <div className="min-w-0 flex-1">
        <div className="text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
          {label}
        </div>
        <div className="mt-0.5 text-sm font-semibold text-text-light dark:text-text-dark">
          {children}
        </div>
      </div>
    </div>
  );
}

function ContactRow({ contact }: { contact: VenueContact }) {
  const { t } = useTranslation();
  let icon = <LinkIcon size={16} />;
  let value: string | null = null;
  let href: string | null = null;
  let kindLabel = t('facilityDetail.website');

  if (contact.phone) {
    icon = <Phone size={16} />;
    value = contact.phone;
    href = `tel:${contact.phone.replace(/\s+/g, '')}`;
    kindLabel = t('facilityDetail.phone');
  } else if (contact.email) {
    icon = <Mail size={16} />;
    value = contact.email;
    href = `mailto:${contact.email}`;
    kindLabel = t('facilityDetail.email');
  } else if (contact.link) {
    icon = <Globe size={16} />;
    value = contact.link.replace(/^https?:\/\//, '');
    href = contact.link.startsWith('http') ? contact.link : `https://${contact.link}`;
    kindLabel = t('facilityDetail.website');
  }

  const label = contact.description?.trim() || kindLabel;

  return (
    <a
      href={href ?? '#'}
      target={contact.link ? '_blank' : undefined}
      rel="noreferrer"
      className="flex items-center gap-3 rounded-lg p-2.5 transition-colors hover:bg-black/[0.04] dark:hover:bg-white/[0.06]"
    >
      <span className="flex h-9 w-9 items-center justify-center rounded-md bg-brand-500/12 text-brand-700 dark:text-brand-300">
        {icon}
      </span>
      <div className="min-w-0 flex-1">
        <div className="truncate text-sm font-bold">{value}</div>
        <div className="text-[11px] uppercase tracking-widest text-muted-light dark:text-muted-dark">
          {label}
        </div>
      </div>
    </a>
  );
}

function MetaCard({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="rounded-lg border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] px-4 py-3">
      <div className="text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
        {label}
      </div>
      <div className="mt-0.5 text-sm font-semibold">{children}</div>
    </div>
  );
}

function summarizeWeeklyHours(
  groups: ReturnType<typeof getScheduleResult>['groups'],
): string {
  const starts: number[] = [];
  const ends: number[] = [];
  for (const g of groups) {
    for (const s of g.schedules) {
      const sh = Number.parseInt(s.start_time.split(':')[0], 10);
      const eh = Number.parseInt(s.end_time.split(':')[0], 10);
      if (!Number.isNaN(sh)) starts.push(sh);
      if (!Number.isNaN(eh)) ends.push(eh);
    }
  }
  if (starts.length === 0) return '—';
  const minS = Math.min(...starts);
  const maxE = Math.max(...ends);
  return `${shortTime(`${minS.toString().padStart(2, '0')}:00:00`)} – ${shortTime(`${maxE.toString().padStart(2, '0')}:00:00`)}`;
}
