import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { BadgePercent, Plus, Trash2, Pencil } from 'lucide-react';
import type { PricingRule } from '@/types/pricing';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { Input, Select } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { formatPriceString, shortTime, WEEKDAY_KEYS } from '@/lib/format';

export function PricingEditor({
  venueId,
  resourceId,
  rules,
  onChange,
  onCreate,
  onUpdate,
  onDelete,
  busy = false,
}: {
  venueId: string;
  resourceId: string;
  rules: PricingRule[];
  onChange: (next: PricingRule[]) => void;
  onCreate?: (rule: PricingRule) => Promise<void>;
  onUpdate?: (rule: PricingRule) => Promise<void>;
  onDelete?: (rule: PricingRule) => Promise<void>;
  busy?: boolean;
}) {
  const { t } = useTranslation();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<PricingRule | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<PricingRule | null>(null);

  async function handleSave(rule: PricingRule) {
    const exists = rules.some((r) => r.id === rule.id);
    if (exists && onUpdate) {
      await onUpdate(rule);
      setEditorOpen(false);
      setEditing(null);
      return;
    }
    if (!exists && onCreate) {
      await onCreate(rule);
      setEditorOpen(false);
      setEditing(null);
      return;
    }
    const next = exists
      ? rules.map((r) => (r.id === rule.id ? rule : r))
      : [...rules, rule];
    onChange(next);
    setEditorOpen(false);
    setEditing(null);
  }
  async function handleDelete(rule: PricingRule) {
    if (onDelete) {
      await onDelete(rule);
      setConfirmDelete(null);
      return;
    }
    onChange(rules.filter((r) => r.id !== rule.id));
  }

  const sorted = [...rules].sort((a, b) => b.priority - a.priority);

  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="text-base font-extrabold">
              {t('resource.pricingTitle')}
            </h3>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark max-w-2xl">
              {t('resource.pricingSubtitle')}
            </p>
          </div>
          <Button
            size="sm"
            leftIcon={<Plus size={14} />}
            loading={busy}
            disabled={busy}
            onClick={() => {
              setEditing(null);
              setEditorOpen(true);
            }}
          >
            {t('resource.addPricing')}
          </Button>
        </div>
      </CardHeader>
      <CardBody>
        {sorted.length === 0 ? (
          <EmptyState
            icon={<BadgePercent size={20} />}
            title={t('resource.noPricing')}
            action={
              <Button
                size="sm"
                leftIcon={<Plus size={14} />}
                loading={busy}
                disabled={busy}
                onClick={() => setEditorOpen(true)}
              >
                {t('resource.addPricing')}
              </Button>
            }
          />
        ) : (
          <div className="divide-y divide-black/5 dark:divide-white/10">
            {sorted.map((r) => (
              <PricingRow
                key={r.id}
                rule={r}
                onEdit={() => {
                  setEditing(r);
                  setEditorOpen(true);
                }}
                onDelete={() => setConfirmDelete(r)}
              />
            ))}
          </div>
        )}
      </CardBody>

      {editorOpen ? (
        <PricingRuleModal
          initial={editing}
          venueId={venueId}
          resourceId={resourceId}
          onClose={() => {
            setEditorOpen(false);
            setEditing(null);
          }}
          onSave={(rule) => {
            void handleSave(rule);
          }}
        />
      ) : null}

      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => {
          if (confirmDelete) void handleDelete(confirmDelete);
        }}
        title={t('resource.deletePricingConfirm')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </Card>
  );
}

function PricingRow({
  rule,
  onEdit,
  onDelete,
}: {
  rule: PricingRule;
  onEdit: () => void;
  onDelete: () => void;
}) {
  const { t } = useTranslation();
  const dayLabel =
    rule.day_of_week == null
      ? t('resource.anyDay')
      : t(`resource.weekdaysLong.${WEEKDAY_KEYS[rule.day_of_week]}`);
  const time =
    rule.start_time && rule.end_time
      ? `${shortTime(rule.start_time)} – ${shortTime(rule.end_time)}`
      : '—';

  return (
    <div className="flex items-center gap-3 py-3">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-warning/15 text-[#b4700a] dark:text-warning">
        <BadgePercent size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <span className="text-[15px] font-extrabold">
            {formatPriceString(rule.price, rule.currency)}
          </span>
          <Badge tone="muted">/ {t('common.perHour')}</Badge>
          {rule.priority > 0 ? (
            <Badge tone="info">
              {t('resource.priority')} · {rule.priority}
            </Badge>
          ) : null}
        </div>
        <div className="mt-0.5 text-xs text-muted-light dark:text-muted-dark">
          {dayLabel} · {time}
          {rule.sport ? ` · ${t(`sports.${rule.sport}`, { defaultValue: rule.sport })}` : ''}
        </div>
      </div>
      <div className="flex items-center gap-1">
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

function PricingRuleModal({
  initial,
  venueId,
  resourceId,
  onClose,
  onSave,
}: {
  initial: PricingRule | null;
  venueId: string;
  resourceId: string;
  onClose: () => void;
  onSave: (rule: PricingRule) => void;
}) {
  const { t } = useTranslation();
  const [price, setPrice] = useState(initial?.price ?? '8000');
  const [currency, setCurrency] = useState(initial?.currency ?? 'KZT');
  const [day, setDay] = useState<'any' | string>(
    initial?.day_of_week == null ? 'any' : String(initial.day_of_week),
  );
  const [start, setStart] = useState(shortTime(initial?.start_time) || '');
  const [end, setEnd] = useState(shortTime(initial?.end_time) || '');
  const [priority, setPriority] = useState(initial?.priority ?? 0);
  const [status, setStatus] = useState<'active' | 'inactive'>(
    initial?.status ?? 'active',
  );

  return (
    <Modal
      open
      onClose={onClose}
      title={initial ? t('common.edit') + ' · ' + t('resource.pricingTitle') : t('resource.addPricing')}
      description={t('resource.pricingSubtitle')}
      size="lg"
      footer={
        <>
          <Button variant="ghost" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button
            onClick={() =>
              onSave({
                id: initial?.id ?? `${resourceId}-pr-${Date.now()}`,
                venue_id: venueId,
                resource_id: resourceId,
                price: String(Number.parseInt(price, 10) || 0),
                currency,
                day_of_week: day === 'any' ? null : Number(day),
                start_time: start ? `${start}:00` : null,
                end_time: end ? `${end}:00` : null,
                sport: initial?.sport ?? null,
                effective_from: initial?.effective_from ?? null,
                effective_to: initial?.effective_to ?? null,
                priority: Number.isFinite(priority) ? priority : 0,
                status,
              })
            }
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Input
          label={t('resource.pricePerHour')}
          type="number"
          inputMode="numeric"
          value={price}
          onChange={(e) => setPrice(e.currentTarget.value)}
          rightAdornment={<span className="text-sm font-bold">{currency}</span>}
        />
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
        <Select
          label={t('resource.dayOfWeek')}
          value={day}
          onChange={(e) => setDay(e.currentTarget.value)}
          options={[
            { value: 'any', label: t('resource.anyDay') },
            ...WEEKDAY_KEYS.map((k, i) => ({
              value: String(i),
              label: t(`resource.weekdaysLong.${k}`),
            })),
          ]}
        />
        <Input
          label={t('resource.priority')}
          type="number"
          value={String(priority)}
          onChange={(e) => setPriority(Number(e.currentTarget.value) || 0)}
          hint="Higher priority overrides base pricing."
        />
        <Input
          label={t('resource.startTime')}
          type="time"
          value={start}
          onChange={(e) => setStart(e.currentTarget.value)}
          hint={t('common.optional')}
        />
        <Input
          label={t('resource.endTime')}
          type="time"
          value={end}
          onChange={(e) => setEnd(e.currentTarget.value)}
          hint={t('common.optional')}
        />
        <Select
          label={t('resource.status')}
          value={status}
          onChange={(e) =>
            setStatus(e.currentTarget.value as 'active' | 'inactive')
          }
          options={[
            { value: 'active', label: t('common.active') },
            { value: 'inactive', label: t('common.inactive') },
          ]}
        />
      </div>
    </Modal>
  );
}
