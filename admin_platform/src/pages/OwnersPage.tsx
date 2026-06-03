import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';

import { adminApi, type AdminOwner } from '@/api/account';
import { adminVenueApi } from '@/api/venues';
import { Button } from '@/components/ui/Button';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Input, Select } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { DataTable } from '@/components/ui/Table';

const PAGE_SIZE = 20;

export function OwnersPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [active, setActive] = useState('true');
  const [selectedOwnerId, setSelectedOwnerId] = useState<string | null>(null);

  const ownersQuery = useQuery({
    queryKey: ['admin-owners', page, active],
    queryFn: () => adminApi.listOwners({ page, page_size: PAGE_SIZE, active: active !== 'false' }),
  });

  const ownerDetailQuery = useQuery({
    queryKey: ['admin-owner-detail', selectedOwnerId],
    queryFn: () => adminApi.ownerDetail(selectedOwnerId!),
    enabled: Boolean(selectedOwnerId),
  });

  const ownerVenuesQuery = useQuery({
    queryKey: ['admin-owner-venues', selectedOwnerId],
    queryFn: () => adminVenueApi.listVenues({ page: 0, page_size: 5, owner_id: selectedOwnerId! }),
    enabled: Boolean(selectedOwnerId),
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      adminApi.updateOwnerStatus(id, isActive),
    onSuccess: (owner) => {
      void queryClient.invalidateQueries({ queryKey: ['admin-owners'] });
      void queryClient.invalidateQueries({ queryKey: ['admin-owner-detail', owner.id] });
      void queryClient.invalidateQueries({ queryKey: ['admin-owner-stats'] });
    },
  });

  const owners = useMemo(() => {
    const rows = ownersQuery.data?.owners ?? [];
    const needle = search.trim().toLowerCase();
    if (!needle) return rows;
    return rows.filter((o) =>
      [o.username, o.email, o.first_name, o.last_name].some((v) =>
        (v ?? '').toLowerCase().includes(needle),
      ),
    );
  }, [ownersQuery.data?.owners, search]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold md:text-3xl">{t('owners.title')}</h1>
        <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">{t('owners.subtitle')}</p>
      </div>

      <Card>
        <CardHeader>
          <div className="grid gap-3 md:grid-cols-[1fr_180px]">
            <Input
              value={search}
              onChange={(e) => setSearch(e.currentTarget.value)}
              placeholder={t('common.searchPlaceholder')}
            />
            <Select
              value={active}
              onChange={(e) => {
                setPage(1);
                setActive(e.currentTarget.value);
              }}
              options={[
                { value: 'true', label: t('common.active') },
                { value: 'false', label: t('common.all') },
              ]}
            />
          </div>
        </CardHeader>
        <CardBody>
          {ownersQuery.isLoading ? (
            <div className="py-10 text-center text-sm text-muted-light dark:text-muted-dark">
              {t('common.loading')}
            </div>
          ) : ownersQuery.isError ? (
            <ErrorState onRetry={() => void ownersQuery.refetch()} />
          ) : (
            <>
              <DataTable
                rows={owners}
                getKey={(row: AdminOwner) => row.id}
                onRowClick={(row: AdminOwner) => setSelectedOwnerId(row.id)}
                empty={t('common.empty')}
                columns={[
                  {
                    key: 'owner',
                    header: t('owners.owner'),
                    cell: (row: AdminOwner) => (
                      <div>
                        <div className="font-bold">{fullName(row) || row.username}</div>
                        <div className="text-xs text-muted-light dark:text-muted-dark">@{row.username}</div>
                      </div>
                    ),
                  },
                  { key: 'email', header: t('owners.email'), cell: (row: AdminOwner) => row.email },
                  {
                    key: 'status',
                    header: t('common.status'),
                    cell: (row: AdminOwner) => (
                      <span
                        className={
                          row.is_active
                            ? 'rounded-full bg-success/10 px-2 py-1 text-xs font-bold text-success'
                            : 'rounded-full bg-danger/10 px-2 py-1 text-xs font-bold text-danger'
                        }
                      >
                        {row.is_active ? t('common.active') : t('common.inactive')}
                      </span>
                    ),
                  },
                  {
                    key: 'created',
                    header: t('owners.createdAt'),
                    cell: (row: AdminOwner) => formatDate(row.created_at),
                  },
                ]}
              />
              <Pagination page={page} total={ownersQuery.data?.total ?? 0} setPage={setPage} />
            </>
          )}
        </CardBody>
      </Card>

      <OwnerDetailsModal
        open={Boolean(selectedOwnerId)}
        onClose={() => setSelectedOwnerId(null)}
        owner={ownerDetailQuery.data}
        venues={ownerVenuesQuery.data?.venues ?? []}
        venueCount={ownerVenuesQuery.data?.total}
        loading={ownerDetailQuery.isLoading || ownerVenuesQuery.isLoading}
        error={ownerDetailQuery.isError || ownerVenuesQuery.isError}
        updating={statusMutation.isPending}
        updateError={statusMutation.isError}
        onToggleStatus={(id, isActive) => statusMutation.mutate({ id, isActive })}
        onRetry={() => {
          void ownerDetailQuery.refetch();
          void ownerVenuesQuery.refetch();
        }}
      />
    </div>
  );
}

function fullName(owner: AdminOwner) {
  return `${owner.first_name ?? ''} ${owner.last_name ?? ''}`.trim();
}

function formatDate(iso: string) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(d);
}

function ErrorState({ onRetry }: { onRetry: () => void }) {
  const { t } = useTranslation();
  return (
    <div className="rounded-lg border border-danger/20 bg-danger/5 p-4 text-sm text-danger">
      Failed to load.{' '}
      <button type="button" onClick={onRetry} className="font-bold underline">
        {t('common.retry')}
      </button>
    </div>
  );
}

function OwnerDetailsModal({
  open,
  onClose,
  owner,
  venues,
  venueCount,
  loading,
  error,
  updating,
  updateError,
  onToggleStatus,
  onRetry,
}: {
  open: boolean;
  onClose: () => void;
  owner?: AdminOwner & { roles?: string[]; updated_at?: string };
  venues: Array<{ id: string; name: string; status: string; city: string; country: string; created_at: string }>;
  venueCount?: number;
  loading: boolean;
  error: boolean;
  updating: boolean;
  updateError: boolean;
  onToggleStatus: (id: string, isActive: boolean) => void;
  onRetry: () => void;
}) {
  return (
    <Modal
      open={open}
      onClose={onClose}
      title={owner ? fullName(owner) || owner.username : 'Owner details'}
      description={owner?.email}
      size="lg"
      footer={
        owner ? (
          <>
            <Button variant="outline" onClick={onClose}>
              Close
            </Button>
            <Button
              variant={owner.is_active ? 'danger' : 'primary'}
              loading={updating}
              onClick={() => onToggleStatus(owner.id, !owner.is_active)}
            >
              {owner.is_active ? 'Block owner' : 'Unblock owner'}
            </Button>
          </>
        ) : null
      }
    >
      {loading ? (
        <div className="py-10 text-center text-sm text-muted-light dark:text-muted-dark">Loading...</div>
      ) : error ? (
        <ErrorState onRetry={onRetry} />
      ) : owner ? (
        <div className="space-y-5">
          <div className="grid gap-3 sm:grid-cols-3">
            <Metric label="Status" value={owner.is_active ? 'Active' : 'Blocked'} tone={owner.is_active ? 'success' : 'danger'} />
            <Metric label="Venues" value={venueCount ?? venues.length} />
            <Metric label="Roles" value={(owner.roles ?? []).join(', ') || 'owner'} />
          </div>

          {updateError ? (
            <div className="rounded-lg border border-danger/20 bg-danger/5 p-3 text-sm text-danger">
              Could not update owner status. Please retry.
            </div>
          ) : null}

          <section>
            <h3 className="mb-2 text-sm font-bold text-text-light dark:text-text-dark">User info</h3>
            <div className="grid gap-x-4 gap-y-3 rounded-lg border border-black/5 p-4 text-sm dark:border-white/10 sm:grid-cols-2">
              <Info label="ID" value={owner.id} />
              <Info label="Username" value={`@${owner.username}`} />
              <Info label="Email" value={owner.email} />
              <Info label="First name" value={owner.first_name || '—'} />
              <Info label="Last name" value={owner.last_name || '—'} />
              <Info label="Created" value={formatDate(owner.created_at)} />
              <Info label="Updated" value={owner.updated_at ? formatDate(owner.updated_at) : '—'} />
            </div>
          </section>

          <section>
            <h3 className="mb-2 text-sm font-bold text-text-light dark:text-text-dark">Venues</h3>
            {venues.length === 0 ? (
              <div className="rounded-lg border border-dashed border-black/10 p-5 text-sm text-muted-light dark:border-white/10 dark:text-muted-dark">
                This owner has no venues.
              </div>
            ) : (
              <div className="divide-y divide-black/5 rounded-lg border border-black/5 dark:divide-white/10 dark:border-white/10">
                {venues.map((venue) => (
                  <div key={venue.id} className="flex items-center justify-between gap-3 px-4 py-3 text-sm">
                    <div className="min-w-0">
                      <div className="truncate font-semibold">{venue.name}</div>
                      <div className="text-xs text-muted-light dark:text-muted-dark">
                        {venue.city}, {venue.country}
                      </div>
                    </div>
                    <span className="shrink-0 rounded-full bg-black/5 px-2 py-1 text-xs font-bold dark:bg-white/10">
                      {venue.status}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </section>
        </div>
      ) : null}
    </Modal>
  );
}

function Metric({ label, value, tone }: { label: string; value: string | number; tone?: 'success' | 'danger' }) {
  const toneClass =
    tone === 'success' ? 'text-success' : tone === 'danger' ? 'text-danger' : 'text-text-light dark:text-text-dark';
  return (
    <div className="rounded-lg border border-black/5 p-4 dark:border-white/10">
      <div className="text-xs font-bold uppercase tracking-wider text-muted-light dark:text-muted-dark">{label}</div>
      <div className={`mt-1 text-xl font-extrabold ${toneClass}`}>{value}</div>
    </div>
  );
}

function Info({ label, value }: { label: string; value: string }) {
  return (
    <div className="min-w-0">
      <div className="text-xs font-semibold text-muted-light dark:text-muted-dark">{label}</div>
      <div className="break-words font-medium text-text-light dark:text-text-dark">{value}</div>
    </div>
  );
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
  const maxPage = Math.max(1, Math.ceil(total / PAGE_SIZE));
  return (
    <div className="mt-4 flex items-center justify-between text-sm text-muted-light dark:text-muted-dark">
      <span>
        Page {page} / {maxPage}
      </span>
      <div className="flex gap-2">
        <button disabled={page <= 1} onClick={() => setPage(page - 1)} className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10">
          Prev
        </button>
        <button disabled={page >= maxPage} onClick={() => setPage(page + 1)} className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10">
          Next
        </button>
      </div>
    </div>
  );
}
