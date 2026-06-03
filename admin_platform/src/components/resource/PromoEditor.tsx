import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Tag, Plus, Trash2, Pencil } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { Input, Select, Textarea } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import {
  usePromos,
  useCreatePromo,
  useUpdatePromo,
  useDeletePromo,
} from '@/hooks/usePromos';
import type {
  Promo,
  PromoCreatePayload,
  PromoUpdatePayload,
  PromoStatus,
} from '@/types/promo';

const DAYS = [
  { value: 0, key: 'sun' },
  { value: 1, key: 'mon' },
  { value: 2, key: 'tue' },
  { value: 3, key: 'wed' },
  { value: 4, key: 'thu' },
  { value: 5, key: 'fri' },
  { value: 6, key: 'sat' },
] as const;

function toDateInput(iso: string | null | undefined): string {
  if (!iso) return '';
  return iso.slice(0, 10);
}

function toIsoDate(dateStr: string, endOfDay = false): string {
  if (!dateStr) return '';
  return endOfDay ? `${dateStr}T23:59:59Z` : `${dateStr}T00:00:00Z`;
}

export function PromoEditor({
  venueId,
  resourceId,
}: {
  venueId: string;
  resourceId: string;
}) {
  const { t } = useTranslation();
  const { data: promos = [], isLoading } = usePromos(venueId, resourceId);
  const createPromo = useCreatePromo(venueId, resourceId);
  const updatePromo = useUpdatePromo(venueId, resourceId);
  const deletePromo = useDeletePromo(venueId, resourceId);

  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<Promo | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<Promo | null>(null);

  const isBusy =
    createPromo.isPending || updatePromo.isPending || deletePromo.isPending;

  async function handleSave(
    payload: PromoCreatePayload | PromoUpdatePayload,
    isNew: boolean,
  ) {
    if (isNew) {
      // Always stamp the resource_id so the promo is scoped to this resource
      // and will be returned when filtering by resource_id.
      await createPromo.mutateAsync({
        ...(payload as PromoCreatePayload),
        resource_id: resourceId,
      });
    } else if (editing) {
      await updatePromo.mutateAsync({
        id: editing.id,
        data: payload as PromoUpdatePayload,
      });
    }
    setEditorOpen(false);
    setEditing(null);
  }

  async function handleDelete(promo: Promo) {
    await deletePromo.mutateAsync(promo.id);
    setConfirmDelete(null);
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="text-base font-extrabold">{t('promo.title')}</h3>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark max-w-2xl">
              {t('promo.subtitle')}
            </p>
          </div>
          <Button
            size="sm"
            leftIcon={<Plus size={14} />}
            loading={isBusy}
            disabled={isBusy}
            onClick={() => {
              setEditing(null);
              setEditorOpen(true);
            }}
          >
            {t('promo.addPromo')}
          </Button>
        </div>
      </CardHeader>

      <CardBody>
        {isLoading ? (
          <p className="text-sm text-muted-light dark:text-muted-dark">
            {t('common.loading')}
          </p>
        ) : promos.length === 0 ? (
          <EmptyState
            icon={<Tag size={20} />}
            title={t('promo.noPromos')}
            action={
              <Button
                size="sm"
                leftIcon={<Plus size={14} />}
                loading={isBusy}
                disabled={isBusy}
                onClick={() => setEditorOpen(true)}
              >
                {t('promo.addPromo')}
              </Button>
            }
          />
        ) : (
          <div className="divide-y divide-black/5 dark:divide-white/10">
            {promos.map((promo) => (
              <PromoRow
                key={promo.id}
                promo={promo}
                onEdit={() => {
                  setEditing(promo);
                  setEditorOpen(true);
                }}
                onDelete={() => setConfirmDelete(promo)}
              />
            ))}
          </div>
        )}
      </CardBody>

      {editorOpen ? (
        <PromoModal
          initial={editing}
          busy={isBusy}
          onClose={() => {
            setEditorOpen(false);
            setEditing(null);
          }}
          onSave={(payload, isNew) => {
            void handleSave(payload, isNew);
          }}
        />
      ) : null}

      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => {
          if (confirmDelete) void handleDelete(confirmDelete);
        }}
        title={t('promo.deleteConfirm')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </Card>
  );
}

// ─── Row ─────────────────────────────────────────────────────────────────────

function PromoRow({
  promo,
  onEdit,
  onDelete,
}: {
  promo: Promo;
  onEdit: () => void;
  onDelete: () => void;
}) {
  const { t } = useTranslation();

  const discountLabel =
    promo.type === 'percentage'
      ? `${promo.discount_percent ?? 0}%`
      : `${promo.discount_minor ?? 0} ${promo.currency}`;

  const validLabel = promo.valid_to
    ? `${toDateInput(promo.valid_from)} → ${toDateInput(promo.valid_to)}`
    : `${t('promo.from')} ${toDateInput(promo.valid_from)}`;

  return (
    <div className="flex items-center gap-3 py-3">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-brand-500/10 text-brand-500 dark:text-brand-400">
        <Tag size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-[15px] font-extrabold">{promo.name}</span>
          <Badge tone={promo.type === 'percentage' ? 'info' : 'warning'}>
            {discountLabel} {t('promo.off')}
          </Badge>
          {promo.code ? (
            <Badge tone="muted">
              <span className="font-mono text-xs">{promo.code}</span>
            </Badge>
          ) : null}
          <Badge tone={promo.status === 'active' ? 'info' : 'muted'}>
            {promo.status === 'active' ? t('common.active') : t('common.inactive')}
          </Badge>
        </div>
        <div className="mt-0.5 text-xs text-muted-light dark:text-muted-dark">
          {validLabel}
          {promo.max_uses != null
            ? ` · ${promo.uses_count}/${promo.max_uses} ${t('promo.uses')}`
            : ''}
        </div>
      </div>
      <div className="flex shrink-0 items-center gap-1">
        <Button variant="ghost" size="sm" leftIcon={<Pencil size={14} />} onClick={onEdit}>
          {t('common.edit')}
        </Button>
        <Button variant="ghost" size="sm" leftIcon={<Trash2 size={14} />} onClick={onDelete}>
          {t('common.delete')}
        </Button>
      </div>
    </div>
  );
}

// ─── Modal ────────────────────────────────────────────────────────────────────

function PromoModal({
  initial,
  busy,
  onClose,
  onSave,
}: {
  initial: Promo | null;
  busy: boolean;
  onClose: () => void;
  onSave: (
    payload: PromoCreatePayload | PromoUpdatePayload,
    isNew: boolean,
  ) => void;
}) {
  const { t } = useTranslation();
  const isNew = !initial;

  const [name, setName] = useState(initial?.name ?? '');
  const [description, setDescription] = useState(initial?.description ?? '');
  const [code, setCode] = useState(initial?.code ?? '');
  const [type, setType] = useState<'percentage' | 'fixed_amount'>(
    initial?.type ?? 'percentage',
  );
  const [discountPercent, setDiscountPercent] = useState(
    initial?.discount_percent != null ? String(initial.discount_percent) : '',
  );
  const [discountMinor, setDiscountMinor] = useState(
    initial?.discount_minor != null ? String(initial.discount_minor) : '',
  );
  const [currency, setCurrency] = useState(initial?.currency ?? 'KZT');
  const [validFrom, setValidFrom] = useState(toDateInput(initial?.valid_from));
  const [validTo, setValidTo] = useState(toDateInput(initial?.valid_to));
  const [maxUses, setMaxUses] = useState(
    initial?.max_uses != null ? String(initial.max_uses) : '',
  );
  const [maxUsesPerUser, setMaxUsesPerUser] = useState(
    initial?.max_uses_per_user != null ? String(initial.max_uses_per_user) : '',
  );
  const [minDuration, setMinDuration] = useState(
    initial?.min_duration_minutes != null
      ? String(initial.min_duration_minutes)
      : '',
  );
  const [minBookingPrice, setMinBookingPrice] = useState(
    initial?.min_booking_price_minor != null
      ? String(initial.min_booking_price_minor)
      : '',
  );
  const [applicableDays, setApplicableDays] = useState<number[]>(
    initial?.applicable_days ?? [],
  );
  const [status, setStatus] = useState<PromoStatus>(
    initial?.status ?? 'active',
  );

  function toggleDay(day: number) {
    setApplicableDays((prev) =>
      prev.includes(day) ? prev.filter((d) => d !== day) : [...prev, day],
    );
  }

  function buildPayload(): PromoCreatePayload | PromoUpdatePayload {
    return {
      name,
      description: description || undefined,
      code: code || undefined,
      type,
      discount_percent:
        type === 'percentage' && discountPercent
          ? Number(discountPercent)
          : undefined,
      discount_minor:
        type === 'fixed_amount' && discountMinor
          ? Number(discountMinor)
          : undefined,
      currency,
      valid_from: validFrom ? toIsoDate(validFrom) : '',
      valid_to: validTo ? toIsoDate(validTo, true) : undefined,
      max_uses: maxUses ? Number(maxUses) : undefined,
      max_uses_per_user: maxUsesPerUser ? Number(maxUsesPerUser) : undefined,
      min_duration_minutes: minDuration ? Number(minDuration) : undefined,
      min_booking_price_minor: minBookingPrice
        ? Number(minBookingPrice)
        : undefined,
      applicable_days: applicableDays,
      status,
    };
  }

  return (
    <Modal
      open
      onClose={onClose}
      title={
        isNew
          ? t('promo.addPromo')
          : `${t('common.edit')} · ${initial?.name ?? ''}`
      }
      description={t('promo.subtitle')}
      size="lg"
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={busy}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={busy}
            disabled={busy}
            onClick={() => onSave(buildPayload(), isNew)}
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        {/* Name — full width */}
        <div className="md:col-span-2">
          <Input
            label={t('promo.name')}
            value={name}
            onChange={(e) => setName(e.currentTarget.value)}
          />
        </div>

        {/* Discount type */}
        <Select
          label={t('promo.type')}
          value={type}
          onChange={(e) =>
            setType(e.currentTarget.value as 'percentage' | 'fixed_amount')
          }
          // Changing type on an existing promo would violate the DB constraint;
          // delete + recreate is the safe flow.
          disabled={!isNew}
          options={[
            { value: 'percentage', label: t('promo.typePercentage') },
            { value: 'fixed_amount', label: t('promo.typeFixed') },
          ]}
        />

        {/* Conditional discount value */}
        {type === 'percentage' ? (
          <Input
            label={t('promo.discountPercent')}
            type="number"
            min={1}
            max={100}
            value={discountPercent}
            onChange={(e) => setDiscountPercent(e.currentTarget.value)}
            rightAdornment={<span className="text-sm font-bold">%</span>}
            hint="1 – 100"
          />
        ) : (
          <Input
            label={t('promo.discountAmount')}
            type="number"
            min={1}
            value={discountMinor}
            onChange={(e) => setDiscountMinor(e.currentTarget.value)}
            rightAdornment={
              <span className="text-sm font-bold">{currency}</span>
            }
            hint={t('promo.minorHint')}
          />
        )}

        {/* Currency */}
        <Select
          label={t('resource.currency')}
          value={currency}
          onChange={(e) => setCurrency(e.currentTarget.value)}
          options={[
            { value: 'KZT', label: 'Kazakhstani tenge (₸)' },
            { value: 'USD', label: 'US dollar ($)' },
            { value: 'EUR', label: 'Euro (€)' },
            { value: 'RUB', label: 'Russian rouble (₽)' },
          ]}
        />

        {/* Status */}
        <Select
          label={t('resource.status')}
          value={status}
          onChange={(e) => setStatus(e.currentTarget.value as PromoStatus)}
          options={[
            { value: 'active', label: t('common.active') },
            { value: 'inactive', label: t('common.inactive') },
          ]}
        />

        {/* Promo code */}
        <Input
          label={t('promo.promoCode')}
          value={code}
          onChange={(e) => setCode(e.currentTarget.value)}
          hint={t('promo.promoCodeHint')}
        />

        {/* Valid from */}
        <Input
          label={t('promo.validFrom')}
          type="date"
          value={validFrom}
          onChange={(e) => setValidFrom(e.currentTarget.value)}
        />

        {/* Valid to */}
        <Input
          label={t('promo.validTo')}
          type="date"
          value={validTo}
          onChange={(e) => setValidTo(e.currentTarget.value)}
          hint={t('common.optional')}
        />

        {/* Max uses */}
        <Input
          label={t('promo.maxUses')}
          type="number"
          min={1}
          value={maxUses}
          onChange={(e) => setMaxUses(e.currentTarget.value)}
          hint={t('common.optional')}
        />

        {/* Max uses per user */}
        <Input
          label={t('promo.maxUsesPerUser')}
          type="number"
          min={1}
          value={maxUsesPerUser}
          onChange={(e) => setMaxUsesPerUser(e.currentTarget.value)}
          hint={t('common.optional')}
        />

        {/* Min duration (minutes) */}
        <Input
          label={t('promo.minDuration')}
          type="number"
          min={1}
          value={minDuration}
          onChange={(e) => setMinDuration(e.currentTarget.value)}
          hint={t('common.optional')}
        />

        {/* Min booking price (minor units) */}
        <Input
          label={t('promo.minBookingPrice')}
          type="number"
          min={1}
          value={minBookingPrice}
          onChange={(e) => setMinBookingPrice(e.currentTarget.value)}
          hint={t('common.optional')}
        />

        {/* Applicable days — full width */}
        <div className="md:col-span-2">
          <p className="mb-2 text-xs font-semibold uppercase tracking-widest text-muted-light dark:text-muted-dark">
            {t('promo.applicableDays')}
          </p>
          <div className="flex flex-wrap gap-2">
            {DAYS.map(({ value, key }) => {
              const active = applicableDays.includes(value);
              return (
                <button
                  key={value}
                  type="button"
                  onClick={() => toggleDay(value)}
                  className={`rounded-md px-3 py-1.5 text-xs font-bold border transition-colors ${
                    active
                      ? 'bg-brand-500 text-white border-brand-500'
                      : 'bg-transparent border-black/10 dark:border-white/15 text-muted-light dark:text-muted-dark hover:border-brand-500/50'
                  }`}
                >
                  {t(`resource.weekdays.${key}`)}
                </button>
              );
            })}
          </div>
          {applicableDays.length === 0 ? (
            <p className="mt-1.5 text-xs text-muted-light dark:text-muted-dark">
              {t('promo.allDays')}
            </p>
          ) : null}
        </div>

        {/* Description — full width */}
        <Textarea
          className="md:col-span-2"
          label={t('promo.description')}
          rows={2}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
          hint={t('common.optional')}
        />
      </div>
    </Modal>
  );
}
