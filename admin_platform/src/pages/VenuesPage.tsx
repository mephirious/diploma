import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Plus } from 'lucide-react';

import { adminApi, type AdminVenueRequest } from '@/api/account';
import { adminVenueApi, type AdminVenue } from '@/api/venues';
import { Button } from '@/components/ui/Button';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Input, Select, Textarea } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { MultiSelect } from '@/components/ui/MultiSelect';
import { DataTable } from '@/components/ui/Table';
import { sortedSportOptions } from '@/lib/sports';

const PAGE_SIZE = 20;

export function VenuesPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('active');
  const [createOpen, setCreateOpen] = useState(false);

  const venuesQuery = useQuery({
    queryKey: ['admin-venues', page, status, search],
    queryFn: () =>
      adminVenueApi.listVenues({
        page,
        page_size: PAGE_SIZE,
        status: status || undefined,
        search: search.trim() || undefined,
      }),
  });

  const approvedRequestsQuery = useQuery({
    queryKey: ['admin-venue-requests', 'approved-for-create'],
    queryFn: () => adminApi.listVenueRequests({ status: 'approved', page: 1, page_size: 100 }),
  });

  const createVenue = useMutation({
    mutationFn: adminVenueApi.create,
    onSuccess: (venue: { id?: string }) => {
      setCreateOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['admin-venues'] });
      void queryClient.invalidateQueries({ queryKey: ['admin-venue-requests'] });
      if (venue.id) navigate(`/venues/${venue.id}`);
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold md:text-3xl">{t('venues.title')}</h1>
          <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">{t('venues.subtitle')}</p>
        </div>
        <Button leftIcon={<Plus size={16} />} onClick={() => setCreateOpen(true)}>
          {t('venues.create')}
        </Button>
      </div>

      <Card>
        <CardHeader>
          <div className="grid gap-3 md:grid-cols-[1fr_180px]">
            <Input
              value={search}
              onChange={(e) => {
                setPage(0);
                setSearch(e.currentTarget.value);
              }}
              placeholder={t('common.searchPlaceholder')}
            />
            <Select
              value={status}
              onChange={(e) => {
                setPage(0);
                setStatus(e.currentTarget.value);
              }}
              options={[
                { value: 'active', label: t('common.active') },
                { value: '', label: t('common.all') },
              ]}
            />
          </div>
        </CardHeader>
        <CardBody>
          {venuesQuery.isLoading ? (
            <div className="py-10 text-center text-sm text-muted-light dark:text-muted-dark">
              {t('common.loading')}
            </div>
          ) : venuesQuery.isError ? (
            <div className="rounded-lg border border-danger/20 bg-danger/5 p-4 text-sm text-danger">
              {t('common.loadError')}
            </div>
          ) : (
            <>
              <DataTable
                rows={venuesQuery.data?.venues ?? []}
                getKey={(row: AdminVenue) => row.id}
                onRowClick={(row: AdminVenue) => navigate(`/venues/${row.id}`)}
                empty={t('common.empty')}
                columns={[
                  {
                    key: 'venue',
                    header: t('venues.venue'),
                    cell: (row: AdminVenue) => (
                      <div>
                        <div className="font-bold">{row.name}</div>
                        <div className="text-xs text-muted-light dark:text-muted-dark">
                          {(row.sports ?? []).join(', ') || '—'}
                        </div>
                      </div>
                    ),
                  },
                  {
                    key: 'location',
                    header: t('venues.location'),
                    cell: (row: AdminVenue) => [row.city, row.country].filter(Boolean).join(', ') || '—',
                  },
                  {
                    key: 'owner',
                    header: t('venues.owner'),
                    cell: (row: AdminVenue) => <OwnerCell venue={row} />,
                  },
                  {
                    key: 'status',
                    header: t('common.status'),
                    cell: (row: AdminVenue) => (
                      <span className="rounded-full bg-admin-500/10 px-2 py-1 text-xs font-bold text-admin-700 dark:text-admin-300">
                        {row.status}
                      </span>
                    ),
                  },
                  {
                    key: 'created',
                    header: t('venues.createdAt'),
                    cell: (row: AdminVenue) => formatDate(row.created_at),
                  },
                ]}
              />
              <Pagination page={page} total={venuesQuery.data?.total ?? 0} setPage={setPage} />
            </>
          )}
        </CardBody>
      </Card>

      <CreateVenueModal
        open={createOpen}
        requests={approvedRequestsQuery.data?.requests ?? []}
        requestsLoading={approvedRequestsQuery.isLoading}
        saving={createVenue.isPending}
        error={createVenue.isError}
        sportOptions={sortedSportOptions(t, i18n.language)}
        onClose={() => setCreateOpen(false)}
        onCreate={(payload) => createVenue.mutate(payload)}
      />
    </div>
  );
}

function CreateVenueModal({
  open,
  requests,
  requestsLoading,
  saving,
  error,
  sportOptions,
  onClose,
  onCreate,
}: {
  open: boolean;
  requests: AdminVenueRequest[];
  requestsLoading: boolean;
  saving: boolean;
  error: boolean;
  sportOptions: Array<{ value: string; label: string }>;
  onClose: () => void;
  onCreate: (payload: {
    venue_request_id: string;
    name: string;
    description: string;
    status: string;
    address_line1: string;
    address_line2?: string;
    city: string;
    region?: string;
    country: string;
    postal_code?: string;
    sports: string[];
    images?: string[];
    contacts?: Array<{ description: string; phone?: string; email?: string; link?: string }>;
    location?: { lat: number; lng: number };
  }) => void;
}) {
  const { t } = useTranslation();
  const [requestId, setRequestId] = useState('');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [status, setStatus] = useState('active');
  const [addressLine1, setAddressLine1] = useState('');
  const [addressLine2, setAddressLine2] = useState('');
  const [city, setCity] = useState('');
  const [region, setRegion] = useState('');
  const [country, setCountry] = useState('Kazakhstan');
  const [postalCode, setPostalCode] = useState('');
  const [sports, setSports] = useState<string[]>([]);
  const [images, setImages] = useState('');
  const [lat, setLat] = useState('');
  const [lng, setLng] = useState('');
  const [contactDescription, setContactDescription] = useState('');
  const [contactPhone, setContactPhone] = useState('');
  const [contactEmail, setContactEmail] = useState('');
  const [contactLink, setContactLink] = useState('');
  const [confirmOpen, setConfirmOpen] = useState(false);

  const selectedRequest = requests.find((request) => request.id === requestId);
  const canCreate =
    Boolean(requestId) &&
    name.trim().length > 0 &&
    description.trim().length > 0 &&
    addressLine1.trim().length > 0 &&
    city.trim().length > 0 &&
    country.trim().length > 0 &&
    sports.length > 0;

  function buildPayload() {
    const imageList = images
      .split(/[\n,]+/)
      .map((item) => item.trim())
      .filter(Boolean);
    const contact =
      contactDescription.trim() &&
      (contactPhone.trim() || contactEmail.trim() || contactLink.trim())
        ? [{
            description: contactDescription.trim(),
            phone: contactPhone.trim() || undefined,
            email: contactEmail.trim() || undefined,
            link: contactLink.trim() || undefined,
          }]
        : undefined;
    const parsedLat = Number(lat);
    const parsedLng = Number(lng);
    const location =
      lat.trim() && lng.trim() && !Number.isNaN(parsedLat) && !Number.isNaN(parsedLng)
        ? { lat: parsedLat, lng: parsedLng }
        : undefined;
    return {
      venue_request_id: requestId,
      name: name.trim(),
      description: description.trim(),
      status,
      address_line1: addressLine1.trim(),
      address_line2: addressLine2.trim() || undefined,
      city: city.trim(),
      region: region.trim() || undefined,
      country: country.trim(),
      postal_code: postalCode.trim() || undefined,
      sports,
      images: imageList.length > 0 ? imageList : undefined,
      contacts: contact,
      location,
    };
  }

  return (
    <>
      <Modal
        open={open}
        onClose={onClose}
        title={t('venues.create')}
        description={t('venues.createSubtitle')}
        size="xl"
        maxHeight="92vh"
        footer={
          <>
            <Button variant="ghost" onClick={onClose} disabled={saving}>
              {t('common.cancel')}
            </Button>
            <Button disabled={!canCreate || requestsLoading} loading={saving} onClick={() => setConfirmOpen(true)}>
              {t('common.create')}
            </Button>
          </>
        }
      >
        <div className="grid gap-4">
          {error ? (
            <div className="rounded-lg border border-danger/20 bg-danger/5 p-3 text-sm text-danger">
              {t('venues.createError')}
            </div>
          ) : null}
          <Select
            label={t('venues.venueRequest')}
            value={requestId}
            onChange={(event) => {
              const nextId = event.currentTarget.value;
              setRequestId(nextId);
              const request = requests.find((item) => item.id === nextId);
              if (request) setName(request.facility_name);
            }}
            options={[
              { value: '', label: requestsLoading ? t('common.loading') : t('venues.selectRequest') },
              ...requests.map((request) => ({
                value: request.id,
                label: `${request.facility_name} - ${request.full_name}`,
              })),
            ]}
          />
          {selectedRequest ? (
            <div className="rounded-lg border border-black/5 bg-black/[0.02] p-3 text-sm dark:border-white/10 dark:bg-white/[0.03]">
              <div className="font-semibold">{selectedRequest.full_name}</div>
              <div className="text-muted-light dark:text-muted-dark">
                @{selectedRequest.user.username} · {selectedRequest.user.email} · {selectedRequest.phone}
              </div>
            </div>
          ) : null}

          <div className="grid gap-4 md:grid-cols-2">
            <Input label={t('venues.name')} value={name} onChange={(e) => setName(e.currentTarget.value)} />
            <Select
              label={t('common.status')}
              value={status}
              onChange={(e) => setStatus(e.currentTarget.value)}
              options={[
                { value: 'active', label: t('common.active') },
                { value: 'draft', label: t('common.draft') },
                { value: 'inactive', label: t('common.inactive') },
              ]}
            />
            <Input label={t('venues.addressLine1')} value={addressLine1} onChange={(e) => setAddressLine1(e.currentTarget.value)} />
            <Input label={t('venues.addressLine2')} value={addressLine2} onChange={(e) => setAddressLine2(e.currentTarget.value)} />
            <Input label={t('facilityDetail.city')} value={city} onChange={(e) => setCity(e.currentTarget.value)} />
            <Input label={t('venues.region')} value={region} onChange={(e) => setRegion(e.currentTarget.value)} />
            <Input label={t('facilityDetail.country')} value={country} onChange={(e) => setCountry(e.currentTarget.value)} />
            <Input label={t('venues.postalCode')} value={postalCode} onChange={(e) => setPostalCode(e.currentTarget.value)} />
            <Input label={t('venues.latitude')} value={lat} onChange={(e) => setLat(e.currentTarget.value)} />
            <Input label={t('venues.longitude')} value={lng} onChange={(e) => setLng(e.currentTarget.value)} />
          </div>
          <Textarea label={t('facilityDetail.description')} rows={3} value={description} onChange={(e) => setDescription(e.currentTarget.value)} />
          <MultiSelect
            label={t('facilityDetail.sportsLabel')}
            hint={t('facilityDetail.sportsHint')}
            options={sportOptions}
            value={sports}
            onChange={setSports}
            error={sports.length === 0 ? t('common.required') : undefined}
          />
          <Textarea
            label={t('venues.images')}
            rows={2}
            value={images}
            onChange={(e) => setImages(e.currentTarget.value)}
            placeholder={t('venues.imagesPlaceholder')}
          />
          <div className="grid gap-4 md:grid-cols-2">
            <Input label={t('facilityDetail.contactDescriptionPlaceholder')} value={contactDescription} onChange={(e) => setContactDescription(e.currentTarget.value)} />
            <Input label={t('facilityDetail.phone')} value={contactPhone} onChange={(e) => setContactPhone(e.currentTarget.value)} />
            <Input label={t('facilityDetail.email')} value={contactEmail} onChange={(e) => setContactEmail(e.currentTarget.value)} />
            <Input label={t('facilityDetail.website')} value={contactLink} onChange={(e) => setContactLink(e.currentTarget.value)} />
          </div>
        </div>
      </Modal>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={() => {
          setConfirmOpen(false);
          onCreate(buildPayload());
        }}
        title={t('venues.confirmCreateTitle')}
        description={t('venues.confirmCreateDescription')}
        confirmLabel={t('common.create')}
        cancelLabel={t('common.cancel')}
      />
    </>
  );
}

function OwnerCell({ venue }: { venue: AdminVenue }) {
  if (!venue.owner) {
    return <span className="font-mono text-xs">{venue.owner_id ?? '—'}</span>;
  }

  return (
    <div>
      <div className="font-bold">{fullName(venue.owner) || venue.owner.username}</div>
      <div className="text-xs text-muted-light dark:text-muted-dark">@{venue.owner.username}</div>
    </div>
  );
}

function fullName(owner: NonNullable<AdminVenue['owner']>) {
  return `${owner.first_name ?? ''} ${owner.last_name ?? ''}`.trim();
}

function formatDate(iso: string) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(d);
}

function Pagination({
  page,
  total,
  setPage,
}: {
  page: number;
  total: number;
  setPage: (page: number) => void;
}) {
  const { t } = useTranslation();
  const maxPage = Math.max(1, Math.ceil(total / PAGE_SIZE));
  return (
    <div className="mt-4 flex items-center justify-between text-sm text-muted-light dark:text-muted-dark">
      <span>
        {t('common.page')} {page + 1} / {maxPage}
      </span>
      <div className="flex gap-2">
        <button disabled={page <= 0} onClick={() => setPage(page - 1)} className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10">
          {t('common.prev')}
        </button>
        <button disabled={page + 1 >= maxPage} onClick={() => setPage(page + 1)} className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10">
          {t('common.next')}
        </button>
      </div>
    </div>
  );
}
