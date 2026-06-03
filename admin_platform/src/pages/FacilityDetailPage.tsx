import { useEffect, useMemo, useState } from 'react';
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

import { buildAddress, shortTime } from '@/lib/format';
import {
  canonicalSportKeys,
  sortSportKeysForDisplay,
  sortedSportOptions,
  sportLabel,
} from '@/lib/sports';
import type { Venue, VenueContact } from '@/types/venue';
import type { Resource } from '@/types/resource';
import type { VenueScheduleResult } from '@/types/schedule';
import { Modal } from '@/components/ui/Modal';
import { Input, Select, Textarea } from '@/components/ui/Input';
import { MultiSelect } from '@/components/ui/MultiSelect';
import {
  useCreateResource,
  useCreateVenueContact,
  useDeleteVenue,
  useDeleteVenueContact,
  useUpdateVenue,
  useUpdateVenueContact,
  useScheduleResult,
  useVenue,
  useVenueResources,
} from '@/hooks/useVenues';
import type { VenueContactPayload } from '@/api/venues';

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
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { facilityId = '' } = useParams();
  const [tab, setTab] = useState<Tab>('overview');
  const [activeImage, setActiveImage] = useState(0);
  const [editVenueOpen, setEditVenueOpen] = useState(false);
  const [createResourceOpen, setCreateResourceOpen] = useState(false);
  const [contactFormOpen, setContactFormOpen] = useState(false);
  const [deleteVenueOpen, setDeleteVenueOpen] = useState(false);
  const [editContactIndex, setEditContactIndex] = useState<number | null>(null);
  const [deleteContactIndex, setDeleteContactIndex] = useState<number | null>(null);

  const { data: venueData, isLoading: venueLoading } = useVenue(facilityId);
  const { data: resourcesData } = useVenueResources(facilityId);
  const { data: scheduleResultData } = useScheduleResult(facilityId);
  const updateVenue = useUpdateVenue(facilityId);
  const deleteVenue = useDeleteVenue();
  const createResource = useCreateResource(facilityId);
  const createContact = useCreateVenueContact(facilityId);
  const updateContact = useUpdateVenueContact(facilityId);
  const deleteContact = useDeleteVenueContact(facilityId);

  const venue = useMemo<Venue | undefined>(() => {
    if (!venueData) return undefined;

    return {
      id: venueData.id,
      name: venueData.name,
      description: venueData.description ?? '',
      status: venueData.status ?? 'active',
      address_line1: venueData.address_line1 ?? '',
      address_line2: venueData.address_line2,
      city: venueData.city ?? '',
      region: venueData.region ?? '',
      country: venueData.country ?? '',
      postal_code: venueData.postal_code ?? '',
      location: venueData.location ?? null,
      contacts: venueData.contacts ?? [],
      sports: venueData.sports ?? [],
      images: venueData.images ?? [],
      resources: [],
      owner_id: venueData.owner_id ?? null,
      timezone: 'Asia/Almaty',
    };
  }, [venueData]);

  const result = useMemo<VenueScheduleResult | null>(() => {
    if (scheduleResultData) {
      return normalizeScheduleResult(scheduleResultData, facilityId);
    }
    if (!facilityId) return null;

    const resources = (resourcesData?.results ?? []) as Resource[];
    return {
      venue_id: facilityId,
      groups: resources.map((resource) => ({
        resource_id: resource.id,
        resource,
        schedules: [],
        pricing: [],
        blackouts: [],
      })),
    };
  }, [scheduleResultData, facilityId, resourcesData]);

  if (venueLoading) {
    return (
      <EmptyState
        icon={<MapPin size={22} />}
        title={t('facilityDetail.loadingTitle')}
        description={t('facilityDetail.loadingDescription')}
      />
    );
  }

  if (!venue || !result) {
    return (
      <EmptyState
        icon={<MapPin size={22} />}
        title={t('facilities.emptyTitle')}
        description={t('facilities.emptyHint')}
        action={
          <Link to="/venues">
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
        to="/venues"
        className="mb-4 inline-flex items-center gap-1.5 text-sm font-semibold text-muted-light hover:text-text-light dark:text-muted-dark dark:hover:text-text-dark"
      >
        <ArrowLeft size={16} /> {t('venues.title')}
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
                <Button
                  variant="secondary"
                  size="sm"
                  leftIcon={<Pencil size={14} />}
                  onClick={() => setEditVenueOpen(true)}
                >
                  {t('common.edit')}
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  leftIcon={<Trash2 size={14} />}
                  onClick={() => setDeleteVenueOpen(true)}
                >
                  {t('common.delete')}
                </Button>
              </div>
              <div className="absolute left-4 bottom-4 right-4 text-white">
                <h1 className="text-2xl font-extrabold drop-shadow md:text-3xl">
                  {venue.name}
                </h1>
                <div className="mt-1.5 flex flex-wrap items-center gap-2">
                  {sortSportKeysForDisplay(venue.sports, t, i18n.language).map((s) => (
                    <span
                      key={s}
                      className="rounded-full bg-white/20 px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide backdrop-blur"
                    >
                      {sportLabel(t, s)}
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

          {tab === 'overview' ? (
            <OverviewTab venue={venue} />
          ) : (
            <ResourcesTab
              result={result}
              onAddResource={() => setCreateResourceOpen(true)}
              adding={createResource.isPending}
            />
          )}
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
                <Button
                  size="sm"
                  variant="ghost"
                  leftIcon={<Plus size={14} />}
                  onClick={() => {
                    setEditContactIndex(null);
                    setContactFormOpen(true);
                  }}
                >
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
                    <li key={i} className="flex items-center gap-1">
                      <div className="min-w-0 flex-1">
                        <ContactRow contact={c} />
                      </div>
                      <IconButton
                        icon={<Pencil size={16} />}
                        aria-label={t('common.edit')}
                        onClick={() => {
                          setEditContactIndex(i);
                          setContactFormOpen(true);
                        }}
                      />
                      <IconButton
                        icon={<Trash2 size={16} />}
                        aria-label={t('common.delete')}
                        tone="danger"
                        onClick={() => setDeleteContactIndex(i)}
                      />
                    </li>
                  ))}
                </ul>
              )}
            </CardBody>
          </Card>
        </aside>
      </div>

      <EditVenueModal
        open={editVenueOpen}
        onClose={() => setEditVenueOpen(false)}
        saving={updateVenue.isPending}
        venue={venue}
        onSave={async (payload) => {
          await updateVenue.mutateAsync(payload);
          setEditVenueOpen(false);
        }}
      />

      <CreateResourceModal
        open={createResourceOpen}
        onClose={() => setCreateResourceOpen(false)}
        saving={createResource.isPending}
        onCreate={async (payload) => {
          await createResource.mutateAsync(payload);
          setCreateResourceOpen(false);
        }}
      />

      <ContactFormModal
        open={contactFormOpen}
        onClose={() => {
          setContactFormOpen(false);
          setEditContactIndex(null);
        }}
        saving={createContact.isPending || updateContact.isPending}
        mode={editContactIndex !== null ? 'edit' : 'create'}
        initial={
          editContactIndex !== null ? venue.contacts[editContactIndex] : undefined
        }
        onSave={async (payload) => {
          if (editContactIndex !== null) {
            await updateContact.mutateAsync({ index: editContactIndex, contact: payload });
          } else {
            await createContact.mutateAsync(payload);
          }
          setContactFormOpen(false);
          setEditContactIndex(null);
        }}
      />

      <ConfirmDialog
        open={deleteVenueOpen}
        onClose={() => setDeleteVenueOpen(false)}
        onConfirm={() => {
          void deleteVenue.mutateAsync(venue.id).then(() => {
            setDeleteVenueOpen(false);
            navigate('/venues');
          });
        }}
        title={t('facilityDetail.deleteConfirm')}
        description={t('facilityDetail.deleteHint')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />

      <ConfirmDialog
        open={deleteContactIndex !== null}
        onClose={() => setDeleteContactIndex(null)}
        onConfirm={() => {
          if (deleteContactIndex === null) return;
          const index = deleteContactIndex;
          void deleteContact.mutateAsync(index).then(() => setDeleteContactIndex(null));
        }}
        title={t('facilityDetail.deleteContactConfirm')}
        description={t('facilityDetail.deleteContactHint')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </div>
  );
}

function OverviewTab({ venue }: { venue: Venue }) {
  const { t, i18n } = useTranslation();
  return (
    <Card>
      <CardHeader>
        <h3 className="text-base font-extrabold">
          {t('facilityDetail.description')}
        </h3>
      </CardHeader>
      <CardBody className="space-y-6">
        <p className="text-[15px] leading-relaxed text-text-light dark:text-text-dark">
          {venue.description || t('common.none')}
        </p>

        {venue.sports.length > 0 ? (
          <div>
            <div className="text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
              {t('facilityDetail.sportsLabel')}
            </div>
            <div className="mt-2 flex flex-wrap gap-2">
              {sortSportKeysForDisplay(venue.sports, t, i18n.language).map((s) => (
                <Badge key={s} tone="neutral">
                  {sportLabel(t, s)}
                </Badge>
              ))}
            </div>
          </div>
        ) : null}

        <div className="grid gap-3 sm:grid-cols-3">
          <MetaCard label={t('facilityDetail.city')}>{venue.city}</MetaCard>
          <MetaCard label={t('facilityDetail.country')}>{venue.country}</MetaCard>
          <MetaCard label={t('facilityDetail.timezone')}>{venue.timezone}</MetaCard>
        </div>
      </CardBody>
    </Card>
  );
}

function ResourcesTab({
  result,
  onAddResource,
  adding,
}: {
  result: VenueScheduleResult;
  onAddResource: () => void;
  adding: boolean;
}) {
  const { t } = useTranslation();

  if (result.groups.length === 0) {
    return (
      <EmptyState
        icon={<Settings2 size={22} />}
        title={t('facilityDetail.noResources')}
        description={t('facilityDetail.manageResources')}
        action={
          <Button leftIcon={<Plus size={16} />} onClick={onAddResource} loading={adding} disabled={adding}>
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
          <Button size="sm" leftIcon={<Plus size={14} />} onClick={onAddResource} loading={adding} disabled={adding}>
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
          />
        ))}
      </CardBody>
    </Card>
  );
}

function EditVenueModal({
  open,
  onClose,
  saving,
  venue,
  onSave,
}: {
  open: boolean;
  onClose: () => void;
  saving: boolean;
  venue: Venue;
  onSave: (payload: { description: string; sports: string[] }) => Promise<void>;
}) {
  const { t, i18n } = useTranslation();
  const [description, setDescription] = useState('');
  const [sports, setSports] = useState<string[]>([]);

  useEffect(() => {
    if (!open) return;
    setDescription(venue.description ?? '');
    setSports(canonicalSportKeys(venue.sports ?? []));
  }, [open, venue]);

  const sportOptions = sortedSportOptions(t, i18n.language);

  const canSave = description.trim().length > 0 && sports.length > 0;

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('facilityDetail.editVenue')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={saving}
            disabled={!canSave}
            onClick={() => {
              void onSave({
                description: description.trim(),
                sports,
              });
            }}
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4">
        <Textarea
          label={t('facilityDetail.description')}
          rows={4}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
        />
        <MultiSelect
          label={t('facilityDetail.sportsLabel')}
          hint={t('facilityDetail.sportsHint')}
          options={sportOptions}
          value={sports}
          onChange={setSports}
          error={sports.length === 0 ? t('common.required') : undefined}
        />
      </div>
    </Modal>
  );
}

type ContactKind = 'phone' | 'email' | 'link';

function contactKindOf(c: VenueContact): ContactKind {
  if (c.phone?.trim()) return 'phone';
  if (c.email?.trim()) return 'email';
  return 'link';
}

function contactValueOf(c: VenueContact): string {
  return (c.phone ?? c.email ?? c.link ?? '').trim();
}

function contactPlaceholder(kind: ContactKind, t: (key: string) => string): string {
  if (kind === 'phone') return t('facilityDetail.contactPhonePlaceholder');
  if (kind === 'email') return t('facilityDetail.contactEmailPlaceholder');
  return t('facilityDetail.contactLinkPlaceholder');
}

function buildContactPayload(
  kind: ContactKind,
  description: string,
  contact: string,
): VenueContactPayload | null {
  const desc = description.trim();
  const value = contact.trim();
  if (!desc || !value) return null;
  if (kind === 'phone') return { description: desc, phone: value };
  if (kind === 'email') return { description: desc, email: value };
  return { description: desc, link: value };
}

function ContactFormModal({
  open,
  onClose,
  saving,
  mode,
  initial,
  onSave,
}: {
  open: boolean;
  onClose: () => void;
  saving: boolean;
  mode: 'create' | 'edit';
  initial?: VenueContact;
  onSave: (payload: VenueContactPayload) => Promise<void>;
}) {
  const { t } = useTranslation();
  const [kind, setKind] = useState<ContactKind>('phone');
  const [description, setDescription] = useState('');
  const [contact, setContact] = useState('');

  useEffect(() => {
    if (!open) return;
    if (initial) {
      const k = contactKindOf(initial);
      setKind(k);
      setDescription(initial.description?.trim() ?? '');
      setContact(contactValueOf(initial));
    } else {
      setKind('phone');
      setDescription('');
      setContact('');
    }
  }, [open, initial]);

  const canSave = description.trim().length > 0 && contact.trim().length > 0;

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={
        mode === 'edit'
          ? t('facilityDetail.editContact')
          : t('facilityDetail.addContact')
      }
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={saving}
            disabled={!canSave}
            onClick={() => {
              const payload = buildContactPayload(kind, description, contact);
              if (!payload) return;
              void onSave(payload);
            }}
          >
            {mode === 'edit' ? t('common.save') : t('common.create')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4">
        <Select
          label={t('facilityDetail.contactType')}
          value={kind}
          onChange={(e) => {
            setKind(e.currentTarget.value as ContactKind);
            setContact('');
          }}
          options={[
            { value: 'phone', label: t('facilityDetail.phone') },
            { value: 'email', label: t('facilityDetail.email') },
            { value: 'link', label: t('facilityDetail.website') },
          ]}
        />
        <Input
          label={t('facilityDetail.description')}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
          placeholder={t('facilityDetail.contactDescriptionPlaceholder')}
        />
        <Input
          label={t('facilityDetail.contact')}
          value={contact}
          onChange={(e) => setContact(e.currentTarget.value)}
          placeholder={contactPlaceholder(kind, t)}
          type={kind === 'email' ? 'email' : kind === 'phone' ? 'tel' : 'url'}
        />
      </div>
    </Modal>
  );
}

function CreateResourceModal({
  open,
  onClose,
  saving,
  onCreate,
}: {
  open: boolean;
  onClose: () => void;
  saving: boolean;
  onCreate: (payload: {
    name: string;
    type: string;
    sport: string;
    capacity: number;
    status: string;
    description?: string;
    surface?: string;
    images?: string[];
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const [name, setName] = useState('');
  const [type, setType] = useState('court');
  const [sport, setSport] = useState('football');
  const [capacity, setCapacity] = useState('2');
  const [status, setStatus] = useState('active');
  const [description, setDescription] = useState('');
  const [surface, setSurface] = useState('');
  const [image, setImage] = useState('');

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('facilityDetail.addResource')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={saving}
            disabled={!name.trim()}
            onClick={() => {
              void onCreate({
                name: name.trim(),
                type,
                sport,
                capacity: Number(capacity) || 1,
                status,
                description: description.trim() || undefined,
                surface: surface.trim() || undefined,
                images: image.trim() ? [image.trim()] : undefined,
              });
            }}
          >
            {t('common.create')}
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
        <Input label={t('resource.sport')} value={sport} onChange={(e) => setSport(e.currentTarget.value)} />
        <Select
          label={t('resource.status')}
          value={status}
          onChange={(e) => setStatus(e.currentTarget.value)}
          options={[
            { value: 'active', label: t('common.active') },
            { value: 'inactive', label: t('common.inactive') },
            { value: 'maintenance', label: 'maintenance' },
          ]}
        />
        <Input label={t('resource.surface')} value={surface} onChange={(e) => setSurface(e.currentTarget.value)} />
        <Input
          className="md:col-span-2"
          label="Cover image URL"
          value={image}
          onChange={(e) => setImage(e.currentTarget.value)}
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

function ResourceCard({
  resource,
  schedulesCount,
  pricingCount,
}: {
  resource: Resource;
  schedulesCount: number;
  pricingCount: number;
}) {
  const { t } = useTranslation();
  const name = resource.name ?? `Resource ${resource.id}`;
  const typeKey = (resource.type ?? 'other') as keyof typeof RESOURCE_TYPE_ICONS;

  return (
    <div
      className="group relative overflow-hidden rounded-xl border border-black/5 dark:border-white/10 bg-surface-light dark:bg-surface-dark shadow-card"
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
          <Metric
            label={t('resource.sport')}
            value={sportLabel(t, resource.sport ?? 'other')}
          />
          <Metric label={t('resource.capacity')} value={resource.capacity != null ? String(resource.capacity) : '—'} />
          <Metric
            label={t('resource.slotsSchedules')}
            value={`${schedulesCount}·${pricingCount}`}
            hint={t('facilityDetail.resourceSummaryHint', { schedules: schedulesCount, pricing: pricingCount })}
          />
        </div>
      </div>
    </div>
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

function normalizeScheduleResult(raw: any, fallbackVenueId: string): VenueScheduleResult {
  const groups = Array.isArray(raw?.groups) ? raw.groups : [];
  return {
    venue_id: raw?.venue_id ?? fallbackVenueId,
    groups: groups
      .filter((g: any) => g?.resource)
      .map((g: any) => ({
        resource_id: g.resource_id ?? g.resource?.id ?? '',
        resource: g.resource,
        schedules: Array.isArray(g.schedules) ? g.schedules : [],
        pricing: Array.isArray(g.pricing) ? g.pricing : [],
        blackouts: Array.isArray(g.blackouts) ? g.blackouts : [],
      })),
  };
}

function summarizeWeeklyHours(
  groups: VenueScheduleResult['groups'],
): string {
  const starts: number[] = [];
  const ends: number[] = [];
  for (const g of groups) {
    for (const s of Array.isArray(g.schedules) ? g.schedules : []) {
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
