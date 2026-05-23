import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  ArrowLeft,
  Pencil,
  Users,
  LayoutDashboard,
  CalendarRange,
  BadgePercent,
  CalendarX2,
  ListOrdered,
  Sparkles,
} from 'lucide-react';

import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { PageHeader } from '@/components/common/PageHeader';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/EmptyState';
import { StatusChip } from '@/components/common/StatusChip';
import { Tabs, type TabItem } from '@/components/ui/Tabs';
import { WeeklyScheduleEditor } from '@/components/resource/WeeklyScheduleEditor';
import { PricingEditor } from '@/components/resource/PricingEditor';
import { BlackoutEditor } from '@/components/resource/BlackoutEditor';
import { SlotPreview } from '@/components/resource/SlotPreview';
import { Modal } from '@/components/ui/Modal';
import { Input, Select, Textarea } from '@/components/ui/Input';

import { formatPriceString } from '@/lib/format';
import type { PricingRule } from '@/types/pricing';
import type { Blackout, ResourceScheduleEntry } from '@/types/schedule';
import type { Resource } from '@/types/resource';
import {
  useCreateBlackout,
  useCreatePricing,
  useCreateSchedule,
  useDeleteBlackout,
  useDeletePricing,
  useDeleteSchedule,
  useUpdateBlackout,
  useUpdatePricing,
  useUpdateResource,
  useUpdateSchedule,
  useVenue,
  useVenueResources,
  useScheduleResult,
} from '@/hooks/useVenues';

type Tab = 'overview' | 'schedules' | 'pricing' | 'blackouts';

export function ResourceDetailPage() {
  const { t } = useTranslation();
  const { facilityId = '', resourceId = '' } = useParams();

  const [editResourceOpen, setEditResourceOpen] = useState(false);
  const { data: venueData, isLoading: venueLoading } = useVenue(facilityId);
  const { data: resourcesData, isLoading: resourcesLoading } = useVenueResources(facilityId);
  const { data: scheduleResultData, isLoading: scheduleLoading } = useScheduleResult(facilityId);

  const updateResource = useUpdateResource(facilityId);
  const createSchedule = useCreateSchedule(facilityId);
  const updateSchedule = useUpdateSchedule(facilityId);
  const deleteSchedule = useDeleteSchedule(facilityId);
  const createPricing = useCreatePricing(facilityId);
  const updatePricing = useUpdatePricing(facilityId);
  const deletePricing = useDeletePricing(facilityId);
  const createBlackout = useCreateBlackout(facilityId);
  const updateBlackout = useUpdateBlackout(facilityId);
  const deleteBlackout = useDeleteBlackout(facilityId);

  const venue = useMemo(() => {
    if (!venueData) return null;
    return {
      id: venueData.id,
      name: venueData.name,
      description: venueData.description ?? '',
      sports: venueData.sports ?? [],
      address_line1: venueData.address_line1 ?? '',
      address_line2: venueData.address_line2,
      city: venueData.city ?? '',
      region: venueData.region ?? '',
      country: venueData.country ?? '',
      postal_code: venueData.postal_code ?? '',
      location: venueData.location ?? null,
      images: venueData.images ?? [],
      contacts: venueData.contacts ?? [],
      status: venueData.status ?? 'active',
      owner_id: venueData.owner_id ?? null,
    };
  }, [venueData]);

  const resource = useMemo<Resource | null>(() => {
    const rows = (resourcesData?.results ?? []) as Resource[];
    return rows.find((r) => r.id === resourceId) ?? null;
  }, [resourcesData, resourceId]);

  const initial = useMemo(() => {
    const group = scheduleResultData?.groups?.find((g: any) => g.resource_id === resourceId);
    if (group) return group;
    if (!resource) return null;
    return {
      resource_id: resource.id,
      resource,
      schedules: [],
      pricing: [],
      blackouts: [],
    };
  }, [scheduleResultData, resourceId, resource]);

  const [tab, setTab] = useState<Tab>('overview');
  const [schedules, setSchedules] = useState<ResourceScheduleEntry[]>(
    initial?.schedules ?? [],
  );
  const [pricing, setPricing] = useState<PricingRule[]>(initial?.pricing ?? []);
  const [blackouts, setBlackouts] = useState<Blackout[]>(
    initial?.blackouts ?? [],
  );

  useEffect(() => {
    setSchedules(initial?.schedules ?? []);
    setPricing(initial?.pricing ?? []);
    setBlackouts(initial?.blackouts ?? []);
  }, [initial]);

  const isBusy =
    createSchedule.isPending ||
    updateSchedule.isPending ||
    deleteSchedule.isPending ||
    createPricing.isPending ||
    updatePricing.isPending ||
    deletePricing.isPending ||
    createBlackout.isPending ||
    updateBlackout.isPending ||
    deleteBlackout.isPending;

  if (venueLoading || resourcesLoading || scheduleLoading) {
    return (
      <EmptyState
        icon={<LayoutDashboard size={22} />}
        title="Loading resource"
        description="Fetching latest data..."
      />
    );
  }

  if (!venue || !initial || !resource) {
    return (
      <EmptyState
        icon={<LayoutDashboard size={22} />}
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

  const displayName = resource.name ?? `Resource ${resource.id}`;
  const basePrice = pricing
    .filter((p) => p.status === 'active' && p.priority === 0)
    .sort((a, b) => Number(a.price) - Number(b.price))[0];

  const tabs: TabItem<Tab>[] = [
    {
      id: 'overview',
      label: t('facilityDetail.overview'),
      icon: <LayoutDashboard size={14} />,
    },
    {
      id: 'schedules',
      label: t('resource.slotsSchedules'),
      icon: <CalendarRange size={14} />,
    },
    {
      id: 'pricing',
      label: t('resource.pricing'),
      icon: <BadgePercent size={14} />,
    },
    {
      id: 'blackouts',
      label: t('resource.blackouts'),
      icon: <CalendarX2 size={14} />,
    },
  ];

  return (
    <div>
      <Link
        to={`/facilities/${facilityId}`}
        className="mb-4 inline-flex items-center gap-1.5 text-sm font-semibold text-muted-light hover:text-text-light dark:text-muted-dark dark:hover:text-text-dark"
      >
        <ArrowLeft size={16} /> {venue.name}
      </Link>

      <div className="grid gap-6 lg:grid-cols-[1.25fr_1fr]">
        <div className="relative overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-surface-light dark:bg-surface-dark shadow-card">
          <div className="relative h-60">
            <img
              src={resource.images[0] ?? 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=1400'}
              alt={displayName}
              className="h-full w-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
            <div className="absolute top-4 left-4">
              <StatusChip status={(resource.status ?? 'active') as 'active' | 'inactive' | 'maintenance'} />
            </div>
            <div className="absolute top-4 right-4">
                <Button
                  variant="secondary"
                  size="sm"
                  leftIcon={<Pencil size={14} />}
                  onClick={() => setEditResourceOpen(true)}
                >
                {t('facilityDetail.editResource')}
              </Button>
            </div>
            <div className="absolute left-4 bottom-4 right-4 text-white">
              <div className="text-xs font-bold uppercase tracking-widest opacity-80">
                {venue.name}
              </div>
              <h1 className="text-2xl font-extrabold drop-shadow md:text-3xl">
                {displayName}
              </h1>
              {resource.description ? (
                <p className="mt-1 max-w-2xl text-sm opacity-90">
                  {resource.description}
                </p>
              ) : null}
            </div>
          </div>
        </div>

        <Card>
          <CardHeader>
            <h3 className="text-base font-extrabold">
              {t('facilityDetail.overview')}
            </h3>
          </CardHeader>
          <CardBody className="grid grid-cols-2 gap-3">
            <Fact
              icon={<Sparkles size={16} />}
              label={t('resource.sport')}
              value={t(`sports.${resource.sport ?? 'other'}`, { defaultValue: '—' })}
            />
            <Fact
              icon={<ListOrdered size={16} />}
              label={t('resource.type')}
              value={t(
                `facilityDetail.resourceTypes.${(resource.type ?? 'other') as 'court'}`,
                { defaultValue: resource.type ?? '—' },
              )}
            />
            <Fact
              icon={<Users size={16} />}
              label={t('resource.capacity')}
              value={resource.capacity != null ? String(resource.capacity) : '—'}
            />
            <Fact
              icon={<LayoutDashboard size={16} />}
              label={t('resource.surface')}
              value={resource.surface ?? '—'}
            />
            {basePrice ? (
              <Fact
                icon={<BadgePercent size={16} />}
                label={t('resource.pricePerHour')}
                value={`${t('common.from')} ${formatPriceString(basePrice.price, basePrice.currency)}`}
                highlight
              />
            ) : null}
            <Fact
              icon={<CalendarRange size={16} />}
              label={t('resource.slotsSchedules')}
              value={`${schedules.length} · ${pricing.length}`}
              hint={`${schedules.length} schedule / ${pricing.length} pricing rules`}
            />
          </CardBody>
        </Card>
      </div>

      <PageHeader
        className="mt-6"
        title={t('resource.manageSlotsSchedules')}
        subtitle={t('resource.weeklySubtitle')}
        actions={<Tabs<Tab> items={tabs} value={tab} onChange={setTab} />}
      />

      {tab === 'overview' ? (
        <div className="space-y-6">
          <SlotPreview
            schedules={schedules}
            pricing={pricing}
            blackouts={blackouts}
          />
          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <h3 className="text-base font-extrabold">
                  {t('resource.weeklyTitle')}
                </h3>
              </CardHeader>
              <CardBody>
                {schedules.length === 0 ? (
                  <EmptyState
                    icon={<CalendarRange size={18} />}
                    title={t('resource.noSchedule')}
                  />
                ) : (
                  <ul className="grid gap-1.5">
                    {schedules
                      .slice()
                      .sort((a, b) => a.day_of_week - b.day_of_week)
                      .map((e) => (
                        <li
                          key={e.id}
                          className="flex items-center justify-between rounded-md bg-black/[0.03] dark:bg-white/[0.04] px-3 py-2 text-sm"
                        >
                          <span className="font-semibold">
                            {t(`resource.weekdaysLong.${['sun','mon','tue','wed','thu','fri','sat'][e.day_of_week] as 'mon'}`)}
                          </span>
                          <span className="font-mono text-muted-light dark:text-muted-dark">
                            {e.start_time.slice(0, 5)} – {e.end_time.slice(0, 5)}
                          </span>
                        </li>
                      ))}
                  </ul>
                )}
              </CardBody>
            </Card>
            <Card>
              <CardHeader>
                <h3 className="text-base font-extrabold">
                  {t('resource.pricingTitle')}
                </h3>
              </CardHeader>
              <CardBody>
                {pricing.length === 0 ? (
                  <EmptyState
                    icon={<BadgePercent size={18} />}
                    title={t('resource.noPricing')}
                  />
                ) : (
                  <ul className="space-y-2">
                    {pricing.map((p) => (
                      <li
                        key={p.id}
                        className="flex items-center justify-between rounded-md bg-black/[0.03] dark:bg-white/[0.04] px-3 py-2 text-sm"
                      >
                        <div className="flex items-center gap-2">
                          <span className="font-extrabold">
                            {formatPriceString(p.price, p.currency)}
                          </span>
                          {p.priority > 0 ? (
                            <Badge tone="warning">
                              {t('resource.priority')} {p.priority}
                            </Badge>
                          ) : null}
                        </div>
                        <span className="text-xs text-muted-light dark:text-muted-dark">
                          {p.day_of_week == null
                            ? t('resource.anyDay')
                            : t(`resource.weekdays.${['sun','mon','tue','wed','thu','fri','sat'][p.day_of_week] as 'mon'}`)}
                          {p.start_time
                            ? ` · ${p.start_time.slice(0, 5)} – ${p.end_time?.slice(0, 5) ?? ''}`
                            : ''}
                        </span>
                      </li>
                    ))}
                  </ul>
                )}
              </CardBody>
            </Card>
          </div>
        </div>
      ) : tab === 'schedules' ? (
        <div className="space-y-6">
          <WeeklyScheduleEditor
            resourceId={resourceId}
            entries={schedules}
            onChange={setSchedules}
            busy={isBusy}
            onCreate={async (entry) => {
              await createSchedule.mutateAsync({
                venue_id: facilityId,
                resource_id: resourceId,
                day_of_week: entry.day_of_week,
                start_time: entry.start_time,
                end_time: entry.end_time,
                timezone: entry.timezone ?? 'Asia/Almaty',
                status: entry.status,
              });
            }}
            onUpdate={async (entry) => {
              await updateSchedule.mutateAsync({
                id: entry.id,
                data: {
                  day_of_week: entry.day_of_week,
                  start_time: entry.start_time,
                  end_time: entry.end_time,
                  timezone: entry.timezone ?? 'Asia/Almaty',
                  status: entry.status,
                },
              });
            }}
            onDelete={async (entry) => {
              await deleteSchedule.mutateAsync(entry.id);
            }}
          />
          <SlotPreview
            schedules={schedules}
            pricing={pricing}
            blackouts={blackouts}
          />
        </div>
      ) : tab === 'pricing' ? (
        <div className="space-y-6">
          <PricingEditor
            venueId={facilityId}
            resourceId={resourceId}
            rules={pricing}
            onChange={setPricing}
            busy={isBusy}
            onCreate={async (rule) => {
              await createPricing.mutateAsync({
                venue_id: facilityId,
                resource_id: resourceId,
                price: Number(rule.price),
                currency: rule.currency,
                day_of_week: rule.day_of_week ?? undefined,
                start_time: rule.start_time ?? undefined,
                end_time: rule.end_time ?? undefined,
                effective_from: rule.effective_from ?? undefined,
                effective_to: rule.effective_to ?? undefined,
                priority: rule.priority,
                status: rule.status,
              });
            }}
            onUpdate={async (rule) => {
              await updatePricing.mutateAsync({
                id: rule.id,
                data: {
                  price: Number(rule.price),
                  currency: rule.currency,
                  day_of_week: rule.day_of_week ?? undefined,
                  start_time: rule.start_time ?? undefined,
                  end_time: rule.end_time ?? undefined,
                  effective_from: rule.effective_from ?? undefined,
                  effective_to: rule.effective_to ?? undefined,
                  priority: rule.priority,
                  status: rule.status,
                },
              });
            }}
            onDelete={async (rule) => {
              await deletePricing.mutateAsync(rule.id);
            }}
          />
          <SlotPreview
            schedules={schedules}
            pricing={pricing}
            blackouts={blackouts}
          />
        </div>
      ) : (
        <div className="space-y-6">
          <BlackoutEditor
            resourceId={resourceId}
            blackouts={blackouts}
            onChange={setBlackouts}
            busy={isBusy}
            onCreate={async (item) => {
              await createBlackout.mutateAsync({
                venue_id: facilityId,
                resource_id: resourceId,
                start_at: item.start_at,
                end_at: item.end_at,
                reason: item.reason,
                status: item.status,
              });
            }}
            onUpdate={async (item) => {
              await updateBlackout.mutateAsync({
                id: item.id,
                data: {
                  start_at: item.start_at,
                  end_at: item.end_at,
                  reason: item.reason,
                  status: item.status,
                },
              });
            }}
            onDelete={async (item) => {
              await deleteBlackout.mutateAsync(item.id);
            }}
          />
          <SlotPreview
            schedules={schedules}
            pricing={pricing}
            blackouts={blackouts}
          />
        </div>
      )}

      <EditResourceModal
        open={editResourceOpen}
        onClose={() => setEditResourceOpen(false)}
        resource={resource}
        saving={updateResource.isPending}
        onSave={async (payload) => {
          await updateResource.mutateAsync({ id: resource.id, data: payload });
          setEditResourceOpen(false);
        }}
      />
    </div>
  );
}

function EditResourceModal({
  open,
  onClose,
  resource,
  saving,
  onSave,
}: {
  open: boolean;
  onClose: () => void;
  resource: Resource;
  saving: boolean;
  onSave: (payload: {
    name?: string;
    description?: string;
    type?: string;
    sport?: string;
    capacity?: number;
    status?: string;
    surface?: string;
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const [name, setName] = useState(resource.name ?? '');
  const [description, setDescription] = useState(resource.description ?? '');
  const [type, setType] = useState(resource.type ?? 'other');
  const [sport, setSport] = useState(resource.sport ?? '');
  const [capacity, setCapacity] = useState(String(resource.capacity ?? ''));
  const [status, setStatus] = useState(resource.status ?? 'active');
  const [surface, setSurface] = useState(resource.surface ?? '');

  useEffect(() => {
    if (!open) return;
    setName(resource.name ?? '');
    setDescription(resource.description ?? '');
    setType(resource.type ?? 'other');
    setSport(resource.sport ?? '');
    setCapacity(String(resource.capacity ?? ''));
    setStatus(resource.status ?? 'active');
    setSurface(resource.surface ?? '');
  }, [open, resource]);

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('facilityDetail.editResource')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={saving}
            onClick={() => {
              void onSave({
                name,
                description,
                type,
                sport,
                capacity: Number(capacity) || 0,
                status,
                surface,
              });
            }}
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Input label={t('resource.name')} value={name} onChange={(e) => setName(e.currentTarget.value)} />
        <Input
          label={t('resource.capacity')}
          type="number"
          value={capacity}
          onChange={(e) => setCapacity(e.currentTarget.value)}
        />
        <Input label={t('resource.sport')} value={sport} onChange={(e) => setSport(e.currentTarget.value)} />
        <Input label={t('resource.surface')} value={surface} onChange={(e) => setSurface(e.currentTarget.value)} />
        <Select
          label={t('resource.type')}
          value={type}
          onChange={(e) => setType(e.currentTarget.value)}
          options={[
            { value: 'court', label: 'court' },
            { value: 'field', label: 'field' },
            { value: 'lane', label: 'lane' },
            { value: 'table', label: 'table' },
            { value: 'hall', label: 'hall' },
            { value: 'other', label: 'other' },
          ]}
        />
        <Select
          label={t('resource.status')}
          value={status ?? 'active'}
          onChange={(e) => setStatus(e.currentTarget.value as 'active' | 'inactive' | 'maintenance')}
          options={[
            { value: 'active', label: t('common.active') },
            { value: 'inactive', label: t('common.inactive') },
            { value: 'maintenance', label: 'maintenance' },
          ]}
        />
        <Textarea
          className="md:col-span-2"
          label={t('facilityDetail.description')}
          rows={3}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
        />
      </div>
    </Modal>
  );
}

function Fact({
  icon,
  label,
  value,
  hint,
  highlight,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  hint?: string;
  highlight?: boolean;
}) {
  return (
    <div
      className={`rounded-lg border px-3 py-2.5 ${
        highlight
          ? 'border-brand-500/30 bg-brand-500/5'
          : 'border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03]'
      }`}
      title={hint}
    >
      <div className="flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
        {icon}
        {label}
      </div>
      <div className="mt-0.5 text-sm font-bold text-text-light dark:text-text-dark">
        {value}
      </div>
    </div>
  );
}
