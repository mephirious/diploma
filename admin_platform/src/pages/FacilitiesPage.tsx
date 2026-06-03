import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  Building2,
  MapPin,
  Search,
  LayoutGrid,
  Rows3,
} from 'lucide-react';

import { Card, CardBody } from '@/components/ui/Card';
import { PageHeader } from '@/components/common/PageHeader';
import { Input, Select } from '@/components/ui/Input';
import { StatusChip } from '@/components/common/StatusChip';
import { EmptyState } from '@/components/ui/EmptyState';
import { Badge } from '@/components/ui/Badge';
import { MOCK_VENUES } from '@/mock/venues';
import { getScheduleResult } from '@/mock/scheduleResults';
import { type Venue } from '@/types/venue';
import { buildAddress } from '@/lib/format';
import { FILTER_SPORT_KEYS, sortSportKeysForDisplay, sortedSportOptions, sportLabel } from '@/lib/sports';
import { cn } from '@/lib/cn';
import { useMyVenues } from '@/hooks/useVenues';

type StatusFilter = 'all' | 'active' | 'draft' | 'suspended';
type SportFilter = 'all' | (typeof FILTER_SPORT_KEYS)[number];
type View = 'grid' | 'list';

export function FacilitiesPage() {
  const { t, i18n } = useTranslation();
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState<StatusFilter>('all');
  const [sport, setSport] = useState<SportFilter>('all');
  const [view, setView] = useState<View>('grid');

  const { data: venueData } = useMyVenues();
  const apiVenues: Venue[] = (venueData?.results ?? []).map((v: any) => ({
    id: v.id,
    name: v.name,
    description: v.description ?? '',
    status: v.status ?? 'active',
    address_line1: v.address_line1 ?? '',
    address_line2: v.address_line2,
    city: v.city ?? '',
    region: v.region ?? '',
    country: v.country ?? '',
    postal_code: v.postal_code ?? '',
    location: v.location ?? null,
    contacts: v.contacts ?? [],
    sports: v.sports ?? [],
    images: v.images ?? [],
    resources: [],
    owner_id: v.owner_id ?? null,
  }));
  const venues: Venue[] = apiVenues.length > 0 ? apiVenues : MOCK_VENUES;

  const filtered = (() => {
    const q = query.trim().toLowerCase();
    return venues.filter((v) => {
      if (status !== 'all' && v.status !== status) return false;
      if (sport !== 'all' && !v.sports.includes(sport)) return false;
      if (!q) return true;
      const hay = [
        v.name,
        v.description,
        v.city,
        v.country,
        v.address_line1,
        v.address_line2 ?? '',
        ...v.sports,
      ]
        .join(' ')
        .toLowerCase();
      return hay.includes(q);
    });
  })();

  return (
    <div>
      <PageHeader
        title={t('facilities.title')}
        subtitle={t('facilities.subtitle')}
      />

      <Card className="mb-6">
        <CardBody className="flex flex-col gap-3 md:flex-row md:items-center md:gap-4">
          <Input
            leftIcon={<Search size={16} />}
            placeholder={t('facilities.searchPlaceholder')}
            value={query}
            onChange={(e) => setQuery(e.currentTarget.value)}
            className="md:max-w-md"
          />
          <div className="flex flex-1 flex-wrap items-center gap-3">
            <Select
              className="max-w-[200px]"
              value={sport}
              onChange={(e) => setSport(e.currentTarget.value as SportFilter)}
              options={[
                { value: 'all', label: t('facilities.filterAllSports') },
                ...sortedSportOptions(t, i18n.language, FILTER_SPORT_KEYS),
              ]}
            />
            <Select
              className="max-w-[200px]"
              value={status}
              onChange={(e) => setStatus(e.currentTarget.value as StatusFilter)}
              options={[
                { value: 'all', label: t('facilities.filterAllStatuses') },
                { value: 'active', label: t('facilities.activeBadge') },
                { value: 'draft', label: t('facilities.draftBadge') },
                { value: 'suspended', label: t('facilities.suspendedBadge') },
              ]}
            />
            <div className="ml-auto flex items-center gap-1 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] p-1">
              <ViewButton
                active={view === 'grid'}
                onClick={() => setView('grid')}
                aria-label="Grid view"
              >
                <LayoutGrid size={16} />
              </ViewButton>
              <ViewButton
                active={view === 'list'}
                onClick={() => setView('list')}
                aria-label="List view"
              >
                <Rows3 size={16} />
              </ViewButton>
            </div>
          </div>
        </CardBody>
      </Card>

      {filtered.length === 0 ? (
        <EmptyState
          icon={<Building2 size={22} />}
          title={t('facilities.emptyTitle')}
          description={t('facilities.emptyHint')}
        />
      ) : view === 'grid' ? (
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
          {filtered.map((v) => (
            <FacilityCard key={v.id} venue={v} />
          ))}
        </div>
      ) : (
        <Card>
          <CardBody className="p-0">
            <div className="divide-y divide-black/5 dark:divide-white/10">
              {filtered.map((v) => (
                <FacilityRow key={v.id} venue={v} />
              ))}
            </div>
          </CardBody>
        </Card>
      )}
    </div>
  );
}

function ViewButton({
  active,
  children,
  ...rest
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { active?: boolean }) {
  return (
    <button
      type="button"
      className={cn(
        'flex h-8 w-8 items-center justify-center rounded-md transition-colors',
        active
          ? 'bg-surface-light text-brand-700 shadow-card dark:bg-surface-dark dark:text-brand-300'
          : 'text-muted-light dark:text-muted-dark hover:text-text-light dark:hover:text-text-dark',
      )}
      {...rest}
    >
      {children}
    </button>
  );
}

function FacilityCard({ venue }: { venue: Venue }) {
  const { t, i18n } = useTranslation();
  const result = getScheduleResult(venue.id);
  const resourceCount = result.groups.length;

  return (
    <Link
      to={`/facilities/${venue.id}`}
      className="group relative block overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-surface-light dark:bg-surface-dark shadow-card transition-all hover:shadow-card-hover"
    >
      <div className="relative h-44 overflow-hidden">
        <img
          src={venue.images[0]}
          alt={venue.name}
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
        <div className="absolute top-3 right-3">
          <StatusChip status={venue.status} />
        </div>
        <div className="absolute left-4 bottom-3 right-4 text-white">
          <div className="flex items-center gap-2">
            {sortSportKeysForDisplay(venue.sports.slice(0, 8), t, i18n.language).slice(0, 2).map((s) => (
              <span
                key={s}
                className="rounded-full bg-white/20 px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide backdrop-blur"
              >
                {sportLabel(t, s)}
              </span>
            ))}
          </div>
          <div className="mt-1.5 text-lg font-extrabold drop-shadow">
            {venue.name}
          </div>
        </div>
      </div>
      <div className="p-4">
        <div className="flex items-center gap-1.5 text-sm text-muted-light dark:text-muted-dark">
          <MapPin size={14} className="shrink-0" />
          <span className="truncate">{buildAddress(venue)}</span>
        </div>
        <div className="mt-3 flex items-center justify-between">
          <Badge tone="brand" outline>
            {t('facilities.resourcesCount', {
              count: resourceCount,
              defaultValue_one: '{{count}} resource',
              defaultValue_other: '{{count}} resources',
            })}
          </Badge>
          <span className="text-xs text-muted-light dark:text-muted-dark">
            {venue.timezone}
          </span>
        </div>
      </div>
    </Link>
  );
}

function FacilityRow({ venue }: { venue: Venue }) {
  const { t, i18n } = useTranslation();
  const result = getScheduleResult(venue.id);

  return (
    <Link
      to={`/facilities/${venue.id}`}
      className="flex items-center gap-4 px-4 py-4 transition-colors hover:bg-black/[0.02] dark:hover:bg-white/[0.04]"
    >
      <img
        src={venue.images[0]}
        alt={venue.name}
        className="h-16 w-24 shrink-0 rounded-lg object-cover"
      />
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <div className="truncate text-base font-bold">{venue.name}</div>
          <StatusChip status={venue.status} />
        </div>
        <div className="mt-0.5 truncate text-sm text-muted-light dark:text-muted-dark">
          {buildAddress(venue)}
        </div>
      </div>
      <div className="hidden md:flex items-center gap-2">
        {sortSportKeysForDisplay(venue.sports.slice(0, 8), t, i18n.language).slice(0, 3).map((s) => (
          <Badge key={s} tone="neutral">
            {sportLabel(t, s)}
          </Badge>
        ))}
      </div>
      <div className="hidden sm:block text-right w-28">
        <div className="text-sm font-bold">{result.groups.length}</div>
        <div className="text-[11px] uppercase tracking-widest text-muted-light dark:text-muted-dark">
          {t('facilityDetail.resources')}
        </div>
      </div>
    </Link>
  );
}
