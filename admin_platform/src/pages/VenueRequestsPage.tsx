import { useEffect, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';

import { adminApi, type AdminVenueRequest, type VenueRequestStatus } from '@/api/account';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Input, Select } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { DataTable } from '@/components/ui/Table';

const PAGE_SIZE = 20;

const statusOptions: Array<VenueRequestStatus | ''> = [
  'created',
  'awaiting',
  'reviewing',
  'approved',
  'cancelled',
  '',
];

export function VenueRequestsPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<VenueRequestStatus | ''>('created');
  const [selected, setSelected] = useState<AdminVenueRequest | null>(null);

  const requestsQuery = useQuery({
    queryKey: ['admin-venue-requests', page, status, search],
    queryFn: () =>
      adminApi.listVenueRequests({
        page,
        page_size: PAGE_SIZE,
        status: status || undefined,
        search: search.trim() || undefined,
      }),
  });

  const documentQuery = useQuery({
    queryKey: ['admin-venue-request-document', selected?.id],
    enabled: !!selected?.doc_path,
    queryFn: () => adminApi.venueRequestDocument(selected!.id),
  });

  const [documentUrl, setDocumentUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!documentQuery.data?.blob) {
      setDocumentUrl(null);
      return;
    }
    const url = URL.createObjectURL(documentQuery.data.blob);
    setDocumentUrl(url);
    return () => URL.revokeObjectURL(url);
  }, [documentQuery.data]);

  const statusMutation = useMutation({
    mutationFn: ({ id, nextStatus }: { id: string; nextStatus: VenueRequestStatus }) =>
      adminApi.updateVenueRequestStatus(id, nextStatus),
    onSuccess: (updated) => {
      setSelected(updated);
      void queryClient.invalidateQueries({ queryKey: ['admin-venue-requests'] });
    },
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold md:text-3xl">{t('venueRequests.title')}</h1>
        <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
          {t('venueRequests.subtitle')}
        </p>
      </div>

      <Card>
        <CardHeader>
          <div className="grid gap-3 md:grid-cols-[1fr_220px]">
            <Input
              value={search}
              onChange={(e) => {
                setPage(1);
                setSearch(e.currentTarget.value);
              }}
              placeholder={t('venueRequests.searchPlaceholder')}
            />
            <Select
              value={status}
              onChange={(e) => {
                setPage(1);
                setStatus(e.currentTarget.value as VenueRequestStatus | '');
              }}
              options={statusOptions.map((value) => ({
                value,
                label: value ? t(`venueRequests.status.${value}`) : t('common.all'),
              }))}
            />
          </div>
        </CardHeader>
        <CardBody>
          {requestsQuery.isLoading ? (
            <div className="py-10 text-center text-sm text-muted-light dark:text-muted-dark">
              {t('common.loading')}
            </div>
          ) : requestsQuery.isError ? (
            <div className="rounded-lg border border-danger/20 bg-danger/5 p-4 text-sm text-danger">
              Failed to load requests
            </div>
          ) : (
            <>
              <DataTable
                rows={requestsQuery.data?.requests ?? []}
                getKey={(row: AdminVenueRequest) => row.id}
                onRowClick={(row: AdminVenueRequest) => setSelected(row)}
                empty={t('common.empty')}
                columns={[
                  {
                    key: 'applicant',
                    header: t('venueRequests.applicant'),
                    cell: (row: AdminVenueRequest) => (
                      <div>
                        <div className="font-bold">{row.full_name}</div>
                        <div className="text-xs text-muted-light dark:text-muted-dark">{row.phone}</div>
                      </div>
                    ),
                  },
                  {
                    key: 'facility',
                    header: t('venueRequests.facility'),
                    cell: (row: AdminVenueRequest) => (
                      <div className="max-w-[280px]">
                        <div className="font-semibold">{row.facility_name}</div>
                        <div className="truncate text-xs text-muted-light dark:text-muted-dark">
                          {row.comment || '—'}
                        </div>
                      </div>
                    ),
                  },
                  {
                    key: 'user',
                    header: t('venueRequests.user'),
                    cell: (row: AdminVenueRequest) => <UserCell request={row} />,
                  },
                  {
                    key: 'status',
                    header: t('common.status'),
                    cell: (row: AdminVenueRequest) => (
                      <Badge tone={statusTone(row.status)}>
                        {t(`venueRequests.status.${row.status}`)}
                      </Badge>
                    ),
                  },
                  {
                    key: 'created',
                    header: t('venueRequests.createdAt'),
                    cell: (row: AdminVenueRequest) => formatDate(row.created_at),
                  },
                  {
                    key: 'updated',
                    header: t('venueRequests.updatedAt'),
                    cell: (row: AdminVenueRequest) => formatDate(row.updated_at),
                  },
                ]}
              />
              <Pagination
                page={page}
                total={requestsQuery.data?.total ?? 0}
                setPage={setPage}
              />
            </>
          )}
        </CardBody>
      </Card>

      <VenueRequestDetailsModal
        request={selected}
        documentUrl={documentUrl}
        documentContentType={documentQuery.data?.contentType ?? ''}
        documentLoading={documentQuery.isLoading}
        documentError={documentQuery.isError}
        statusPending={statusMutation.isPending}
        onStatusChange={(nextStatus) => {
          if (!selected) return;
          statusMutation.mutate({ id: selected.id, nextStatus });
        }}
        onClose={() => setSelected(null)}
      />
    </div>
  );
}

function UserCell({ request }: { request: AdminVenueRequest }) {
  const name = `${request.user.first_name ?? ''} ${request.user.last_name ?? ''}`.trim();

  return (
    <div>
      <div className="font-bold">{name || request.user.username}</div>
      <div className="text-xs text-muted-light dark:text-muted-dark">
        @{request.user.username} · {request.user.email}
      </div>
    </div>
  );
}

function statusTone(status: VenueRequestStatus) {
  switch (status) {
    case 'awaiting':
      return 'warning';
    case 'created':
      return 'neutral';
    case 'reviewing':
      return 'info';
    case 'approved':
      return 'success';
    case 'cancelled':
      return 'danger';
  }
}

function VenueRequestDetailsModal({
  request,
  documentUrl,
  documentContentType,
  documentLoading,
  documentError,
  statusPending,
  onStatusChange,
  onClose,
}: {
  request: AdminVenueRequest | null;
  documentUrl: string | null;
  documentContentType: string;
  documentLoading: boolean;
  documentError: boolean;
  statusPending: boolean;
  onStatusChange: (status: VenueRequestStatus) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [confirmStatus, setConfirmStatus] = useState<VenueRequestStatus | null>(null);
  if (!request) return null;

  const normalizedContentType = documentContentType.toLowerCase();
  const isPdf = normalizedContentType.includes('application/pdf');
  const isImage = normalizedContentType.startsWith('image/');
  const isUnexpectedDocument =
    !!request.doc_path && !!documentContentType && !isPdf && !isImage;

  return (
    <Modal
      open={!!request}
      onClose={onClose}
      title={request.facility_name}
      description={request.id}
      size="xl"
      maxHeight="92vh"
    >
      <div className="space-y-5">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="flex flex-wrap items-center gap-2">
            <Badge tone={statusTone(request.status)}>
              {t(`venueRequests.status.${request.status}`)}
            </Badge>
            <span className="text-xs text-muted-light dark:text-muted-dark">
              {formatDate(request.created_at)}
            </span>
          </div>
          <div className="flex flex-wrap gap-2">
            <Button
              size="sm"
              variant="outline"
              loading={statusPending && confirmStatus === 'approved'}
              disabled={statusPending || request.status === 'approved'}
              onClick={() => setConfirmStatus('approved')}
            >
              {t('venueRequests.approve')}
            </Button>
            <Button
              size="sm"
              variant="danger"
              loading={statusPending && confirmStatus === 'cancelled'}
              disabled={statusPending || request.status === 'cancelled'}
              onClick={() => setConfirmStatus('cancelled')}
            >
              {t('venueRequests.decline')}
            </Button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <DetailBlock label={t('venueRequests.applicant')} value={request.full_name} />
          <DetailBlock label={t('venueRequests.phone')} value={request.phone || '—'} />
          <DetailBlock label={t('venueRequests.facility')} value={request.facility_name} />
          <DetailBlock label={t('venueRequests.user')} value={`@${request.user.username}`} />
          <DetailBlock label="Email" value={request.user.email} />
          <DetailBlock label="User ID" value={request.user_id} mono />
          <DetailBlock label={t('venueRequests.createdAt')} value={formatDate(request.created_at)} />
          <DetailBlock label={t('venueRequests.updatedAt')} value={formatDate(request.updated_at)} />
        </div>

        <div>
          <div className="mb-2 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
            {t('venueRequests.comment')}
          </div>
          <div className="rounded-lg border border-black/5 bg-black/[0.02] p-4 text-sm dark:border-white/10 dark:bg-white/[0.03]">
            {request.comment || '—'}
          </div>
        </div>

        <div>
          <div className="mb-3 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
            {t('venueRequests.document')}
          </div>
          <div className="flex min-h-[280px] items-center justify-center rounded-lg border border-black/5 bg-black/[0.02] p-4 dark:border-white/10 dark:bg-white/[0.03]">
            {!request.doc_path ? (
              <span className="text-sm text-muted-light dark:text-muted-dark">—</span>
            ) : documentLoading ? (
              <span className="text-sm text-muted-light dark:text-muted-dark">{t('common.loading')}</span>
            ) : documentError || !documentUrl ? (
              <span className="text-sm text-danger">Failed to load document</span>
            ) : isUnexpectedDocument ? (
              <span className="text-sm text-danger">
                Unexpected document response: {documentContentType || 'unknown content type'}
              </span>
            ) : isPdf ? (
              <iframe title="Venue request document" src={documentUrl} className="h-[520px] w-full rounded-md border-0" />
            ) : isImage ? (
              <img
                src={documentUrl}
                alt="Venue request document"
                className="max-h-[520px] max-w-full rounded-md object-contain"
              />
            ) : (
              <span className="text-sm text-danger">Unsupported document type</span>
            )}
          </div>
        </div>
      </div>
      <ConfirmDialog
        open={!!confirmStatus}
        onClose={() => setConfirmStatus(null)}
        onConfirm={() => {
          if (confirmStatus) onStatusChange(confirmStatus);
        }}
        title={confirmStatus === 'approved' ? t('venueRequests.confirmApproveTitle') : t('venueRequests.confirmDeclineTitle')}
        description={confirmStatus === 'approved' ? t('venueRequests.confirmApproveDescription') : t('venueRequests.confirmDeclineDescription')}
        confirmLabel={confirmStatus === 'approved' ? t('venueRequests.approve') : t('venueRequests.decline')}
        cancelLabel={t('common.back')}
        tone={confirmStatus === 'cancelled' ? 'danger' : 'brand'}
      />
    </Modal>
  );
}

function DetailBlock({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="rounded-lg border border-black/5 bg-black/[0.02] p-4 dark:border-white/10 dark:bg-white/[0.03]">
      <div className="mb-1 text-xs font-bold uppercase tracking-wide text-muted-light dark:text-muted-dark">
        {label}
      </div>
      <div className={mono ? 'break-all font-mono text-xs' : 'break-words text-sm font-semibold'}>
        {value}
      </div>
    </div>
  );
}

function formatDate(iso: string) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium', timeStyle: 'short' }).format(d);
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
        <button
          disabled={page <= 1}
          onClick={() => setPage(page - 1)}
          className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10"
        >
          Prev
        </button>
        <button
          disabled={page >= maxPage}
          onClick={() => setPage(page + 1)}
          className="rounded-md border border-black/10 px-3 py-1.5 disabled:opacity-40 dark:border-white/10"
        >
          Next
        </button>
      </div>
    </div>
  );
}
