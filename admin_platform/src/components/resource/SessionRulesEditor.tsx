import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CalendarClock, Copy, Link2, Plus, Trash2, Pencil } from 'lucide-react';

import type { SessionTemplate, TemplateCreatePayload, TemplateUpdatePayload } from '@/types/session';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { Input, Select, Textarea } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { formatPrice, WEEKDAY_KEYS } from '@/lib/format';

type EditorMode = 'scheduled' | 'open';

export function SessionRulesEditor({
  venueId: _venueId,
  resourceId,
  sport,
  templates,
  onCreateTemplate,
  onUpdateTemplate,
  onArchiveTemplate,
  onRegenerateInvite,
  onCreateInstance,
  busy = false,
}: {
  venueId: string;
  resourceId: string;
  sport: string;
  templates: SessionTemplate[];
  onCreateTemplate: (payload: TemplateCreatePayload) => Promise<void>;
  onUpdateTemplate: (id: string, payload: TemplateUpdatePayload) => Promise<void>;
  onArchiveTemplate: (id: string) => Promise<void>;
  onRegenerateInvite: (id: string) => Promise<void>;
  onCreateInstance: (payload: {
    name: string;
    description?: string;
    mode: EditorMode;
    sport: string;
    starts_at: string;
    ends_at: string;
    timezone: string;
    min_participants: number;
    max_participants: number;
    pricing_model: 'fixed_split' | 'per_person';
    price_total_minor?: number;
    price_per_person_minor?: number;
    currency: string;
    lock_before_minutes: number;
    visibility: 'public' | 'link_only' | 'private';
  }) => Promise<void>;
  busy?: boolean;
}) {
  const { t } = useTranslation();
  const [ruleModal, setRuleModal] = useState<'create' | SessionTemplate | null>(null);
  const [instanceOpen, setInstanceOpen] = useState(false);
  const [confirmArchive, setConfirmArchive] = useState<SessionTemplate | null>(null);

  const active = templates.filter((x) => x.status !== 'archived');

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <h3 className="text-base font-extrabold">{t('sessions.rulesTitle')}</h3>
              <p className="mt-1 max-w-2xl text-sm text-muted-light dark:text-muted-dark">
                {t('sessions.rulesSubtitle')}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <Button
                variant="outline"
                size="sm"
                leftIcon={<CalendarClock size={14} />}
                onClick={() => setInstanceOpen(true)}
                disabled={busy}
              >
                {t('sessions.createOneOff')}
              </Button>
              <Button
                size="sm"
                leftIcon={<Plus size={14} />}
                onClick={() => setRuleModal('create')}
                disabled={busy}
              >
                {t('sessions.addRule')}
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardBody>
          {active.length === 0 ? (
            <EmptyState
              icon={<CalendarClock size={18} />}
              title={t('sessions.noRules')}
              description={t('sessions.noRulesHint')}
            />
          ) : (
            <ul className="space-y-3">
              {active.map((tpl) => (
                <li
                  key={tpl.id}
                  className="rounded-lg border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] p-4"
                >
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-extrabold text-text-light dark:text-text-dark">
                          {tpl.name}
                        </span>
                        <Badge tone={tpl.status === 'active' ? 'success' : 'warning'}>
                          {t(`sessions.templateStatus.${tpl.status}`)}
                        </Badge>
                        <Badge tone="info">{t(`sessions.mode.${tpl.mode}`)}</Badge>
                      </div>
                      <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
                        {tpl.day_of_week != null && tpl.start_time && tpl.end_time
                          ? `${t(`resource.weekdaysLong.${WEEKDAY_KEYS[tpl.day_of_week]}`)} · ${tpl.start_time.slice(0, 5)} – ${tpl.end_time.slice(0, 5)}`
                          : '—'}
                        {' · '}
                        {tpl.min_participants}–{tpl.max_participants} {t('sessions.players')}
                      </p>
                      <p className="mt-0.5 text-xs text-muted-light dark:text-muted-dark">
                        {tpl.pricing_model === 'fixed_split' && tpl.price_total_minor != null
                          ? `${t('sessions.fixedSplit')}: ${formatPrice(tpl.price_total_minor, tpl.currency)}`
                          : tpl.price_per_person_minor != null
                            ? `${formatPrice(tpl.price_per_person_minor, tpl.currency)} / ${t('sessions.person')}`
                            : '—'}
                        {' · '}
                        {t(`sessions.visibility.${tpl.visibility}`)}
                      </p>
                      {tpl.invite_code ? (
                        <div className="mt-2 flex items-center gap-2 text-xs font-mono text-muted-light dark:text-muted-dark">
                          <Link2 size={12} />
                          {tpl.invite_code}
                          <button
                            type="button"
                            className="rounded p-1 hover:bg-black/5 dark:hover:bg-white/10"
                            onClick={() => void navigator.clipboard.writeText(tpl.invite_code ?? '')}
                          >
                            <Copy size={12} />
                          </button>
                        </div>
                      ) : null}
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      {tpl.visibility === 'link_only' ? (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => void onRegenerateInvite(tpl.id)}
                          disabled={busy}
                        >
                          {t('sessions.regenerateInvite')}
                        </Button>
                      ) : null}
                      <Button
                        variant="ghost"
                        size="sm"
                        leftIcon={<Pencil size={14} />}
                        onClick={() => setRuleModal(tpl)}
                        disabled={busy}
                      >
                        {t('common.edit')}
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        leftIcon={<Trash2 size={14} />}
                        onClick={() => setConfirmArchive(tpl)}
                        disabled={busy}
                        className="text-danger hover:bg-danger/10"
                      >
                        {t('common.delete')}
                      </Button>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </CardBody>
      </Card>

      <RuleModal
        open={ruleModal !== null}
        initial={ruleModal === 'create' ? null : ruleModal}
        sport={sport}
        resourceId={resourceId}
        saving={busy}
        onClose={() => setRuleModal(null)}
        onSave={async (payload, id) => {
          if (id) {
            await onUpdateTemplate(id, payload);
          } else {
            await onCreateTemplate(payload as TemplateCreatePayload);
          }
          setRuleModal(null);
        }}
      />

      <InstanceModal
        open={instanceOpen}
        sport={sport}
        resourceId={resourceId}
        saving={busy}
        onClose={() => setInstanceOpen(false)}
        onSave={async (payload) => {
          await onCreateInstance(payload);
          setInstanceOpen(false);
        }}
      />

      <ConfirmDialog
        open={!!confirmArchive}
        onClose={() => setConfirmArchive(null)}
        onConfirm={async () => {
          if (confirmArchive) await onArchiveTemplate(confirmArchive.id);
          setConfirmArchive(null);
        }}
        title={t('sessions.archiveRuleConfirm')}
        description={t('sessions.archiveRuleHint')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </div>
  );
}

function RuleModal({
  open,
  initial,
  sport,
  resourceId,
  saving,
  onClose,
  onSave,
}: {
  open: boolean;
  initial: SessionTemplate | null;
  sport: string;
  resourceId: string;
  saving: boolean;
  onClose: () => void;
  onSave: (payload: TemplateCreatePayload | TemplateUpdatePayload, id?: string) => Promise<void>;
}) {
  const { t } = useTranslation();
  const isEdit = !!initial;

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [mode, setMode] = useState<EditorMode>('scheduled');
  const [dayOfWeek, setDayOfWeek] = useState('1');
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('11:00');
  const [timezone, setTimezone] = useState('Asia/Almaty');
  const [effectiveFrom, setEffectiveFrom] = useState('');
  const [effectiveTo, setEffectiveTo] = useState('');
  const [minParticipants, setMinParticipants] = useState('4');
  const [maxParticipants, setMaxParticipants] = useState('10');
  const [pricingModel, setPricingModel] = useState<'fixed_split' | 'per_person'>('fixed_split');
  const [priceTotal, setPriceTotal] = useState('20000');
  const [pricePerPerson, setPricePerPerson] = useState('2000');
  const [currency, setCurrency] = useState('KZT');
  const [lockBefore, setLockBefore] = useState('60');
  const [visibility, setVisibility] = useState<'public' | 'link_only' | 'private'>('public');
  const [status, setStatus] = useState<'active' | 'paused'>('active');

  useEffect(() => {
    if (!open) return;
    if (initial) {
      setName(initial.name);
      setDescription(initial.description ?? '');
      setMode(initial.mode === 'open' ? 'open' : 'scheduled');
      setDayOfWeek(String(initial.day_of_week ?? 1));
      setStartTime(initial.start_time?.slice(0, 5) ?? '09:00');
      setEndTime(initial.end_time?.slice(0, 5) ?? '11:00');
      setTimezone(initial.timezone || 'Asia/Almaty');
      setEffectiveFrom(initial.effective_from?.slice(0, 10) ?? '');
      setEffectiveTo(initial.effective_to?.slice(0, 10) ?? '');
      setMinParticipants(String(initial.min_participants));
      setMaxParticipants(String(initial.max_participants));
      setPricingModel(initial.pricing_model);
      setPriceTotal(String(initial.price_total_minor ?? 20000));
      setPricePerPerson(String(initial.price_per_person_minor ?? 2000));
      setCurrency(initial.currency || 'KZT');
      setLockBefore(String(initial.lock_before_minutes));
      setVisibility(initial.visibility);
      setStatus(initial.status === 'paused' ? 'paused' : 'active');
    } else {
      setName('');
      setDescription('');
      setMode('scheduled');
      setDayOfWeek('1');
      setStartTime('09:00');
      setEndTime('11:00');
      setTimezone('Asia/Almaty');
      setEffectiveFrom(new Date().toISOString().slice(0, 10));
      setEffectiveTo('');
      setMinParticipants('4');
      setMaxParticipants('10');
      setPricingModel('fixed_split');
      setPriceTotal('20000');
      setPricePerPerson('2000');
      setCurrency('KZT');
      setLockBefore('60');
      setVisibility('public');
      setStatus('active');
    }
  }, [open, initial]);

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={isEdit ? t('sessions.editRule') : t('sessions.addRule')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>
            {t('common.cancel')}
          </Button>
          <Button
            loading={saving}
            onClick={() => {
              if (isEdit && initial) {
                void onSave(
                  {
                    name,
                    description: description || undefined,
                    effective_to: effectiveTo || undefined,
                    min_participants: Number(minParticipants) || 2,
                    max_participants: Number(maxParticipants) || 2,
                    pricing_model: pricingModel,
                    price_total_minor:
                      pricingModel === 'fixed_split' ? Number(priceTotal) || undefined : undefined,
                    price_per_person_minor:
                      pricingModel === 'per_person' ? Number(pricePerPerson) || undefined : undefined,
                    currency,
                    lock_before_minutes: Number(lockBefore) || 60,
                    visibility,
                    status,
                  },
                  initial.id,
                );
                return;
              }
              void onSave({
                resource_id: resourceId,
                name,
                description: description || undefined,
                mode,
                sport,
                day_of_week: Number(dayOfWeek),
                start_time: startTime,
                end_time: endTime,
                timezone,
                effective_from: effectiveFrom,
                effective_to: effectiveTo || undefined,
                min_participants: Number(minParticipants) || (mode === 'open' ? 1 : 2),
                max_participants: Number(maxParticipants) || 2,
                pricing_model: pricingModel,
                price_total_minor:
                  pricingModel === 'fixed_split' ? Number(priceTotal) || undefined : undefined,
                price_per_person_minor:
                  pricingModel === 'per_person' ? Number(pricePerPerson) || undefined : undefined,
                currency,
                lock_before_minutes: Number(lockBefore) || 60,
                visibility,
              });
            }}
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2 max-h-[70vh] overflow-y-auto pr-1">
        <Input label={t('sessions.ruleName')} value={name} onChange={(e) => setName(e.currentTarget.value)} />
        {!isEdit ? (
          <Select
            label={t('sessions.modeLabel')}
            value={mode}
            onChange={(e) => {
              const m = e.currentTarget.value as EditorMode;
              setMode(m);
              if (m === 'open') {
                setPricingModel('per_person');
                setMinParticipants('1');
              }
            }}
            options={[
              { value: 'scheduled', label: t('sessions.mode.scheduled') },
              { value: 'open', label: t('sessions.mode.open') },
            ]}
          />
        ) : (
          <Select
            label={t('resource.status')}
            value={status}
            onChange={(e) => setStatus(e.currentTarget.value as 'active' | 'paused')}
            options={[
              { value: 'active', label: t('common.active') },
              { value: 'paused', label: t('sessions.templateStatus.paused') },
            ]}
          />
        )}
        {!isEdit ? (
          <>
            <Select
              label={t('sessions.dayOfWeek')}
              value={dayOfWeek}
              onChange={(e) => setDayOfWeek(e.currentTarget.value)}
              options={WEEKDAY_KEYS.map((k, i) => ({
                value: String(i),
                label: t(`resource.weekdaysLong.${k}`),
              }))}
            />
            <Input label={t('sessions.startTime')} type="time" value={startTime} onChange={(e) => setStartTime(e.currentTarget.value)} />
            <Input label={t('sessions.endTime')} type="time" value={endTime} onChange={(e) => setEndTime(e.currentTarget.value)} />
            <Input label={t('sessions.timezone')} value={timezone} onChange={(e) => setTimezone(e.currentTarget.value)} />
            <Input label={t('sessions.effectiveFrom')} type="date" value={effectiveFrom} onChange={(e) => setEffectiveFrom(e.currentTarget.value)} />
            <Input label={t('sessions.effectiveTo')} type="date" value={effectiveTo} onChange={(e) => setEffectiveTo(e.currentTarget.value)} />
          </>
        ) : null}
        <Input label={t('sessions.minPlayers')} type="number" value={minParticipants} onChange={(e) => setMinParticipants(e.currentTarget.value)} />
        <Input label={t('sessions.maxPlayers')} type="number" value={maxParticipants} onChange={(e) => setMaxParticipants(e.currentTarget.value)} />
        <Select
          label={t('sessions.pricingModel')}
          value={pricingModel}
          onChange={(e) => setPricingModel(e.currentTarget.value as 'fixed_split' | 'per_person')}
          options={[
            { value: 'fixed_split', label: t('sessions.fixedSplit') },
            { value: 'per_person', label: t('sessions.perPerson') },
          ]}
        />
        {pricingModel === 'fixed_split' ? (
          <Input label={t('sessions.totalPrice')} type="number" value={priceTotal} onChange={(e) => setPriceTotal(e.currentTarget.value)} />
        ) : (
          <Input label={t('sessions.pricePerPerson')} type="number" value={pricePerPerson} onChange={(e) => setPricePerPerson(e.currentTarget.value)} />
        )}
        <Input label={t('sessions.lockBefore')} type="number" value={lockBefore} onChange={(e) => setLockBefore(e.currentTarget.value)} />
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
          rows={2}
          value={description}
          onChange={(e) => setDescription(e.currentTarget.value)}
        />
      </div>
    </Modal>
  );
}

function InstanceModal({
  open,
  sport,
  resourceId,
  saving,
  onClose,
  onSave,
}: {
  open: boolean;
  sport: string;
  resourceId: string;
  saving: boolean;
  onClose: () => void;
  onSave: (payload: {
    name: string;
    description?: string;
    mode: EditorMode;
    sport: string;
    starts_at: string;
    ends_at: string;
    timezone: string;
    min_participants: number;
    max_participants: number;
    pricing_model: 'fixed_split' | 'per_person';
    price_total_minor?: number;
    price_per_person_minor?: number;
    currency: string;
    lock_before_minutes: number;
    visibility: 'public' | 'link_only' | 'private';
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const [name, setName] = useState('');
  const [mode, setMode] = useState<EditorMode>('scheduled');
  const [startsAt, setStartsAt] = useState('');
  const [endsAt, setEndsAt] = useState('');
  const [minParticipants, setMinParticipants] = useState('4');
  const [maxParticipants, setMaxParticipants] = useState('10');
  const [pricingModel, setPricingModel] = useState<'fixed_split' | 'per_person'>('fixed_split');
  const [priceTotal, setPriceTotal] = useState('20000');
  const [pricePerPerson, setPricePerPerson] = useState('2000');

  useEffect(() => {
    if (!open) return;
    setName('');
    setMode('scheduled');
    setStartsAt('');
    setEndsAt('');
    setMinParticipants('4');
    setMaxParticipants('10');
    setPricingModel('fixed_split');
    setPriceTotal('20000');
    setPricePerPerson('2000');
  }, [open]);

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('sessions.createOneOff')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={saving}>{t('common.cancel')}</Button>
          <Button
            loading={saving}
            onClick={() =>
              void onSave({
                name,
                mode,
                sport,
                starts_at: new Date(startsAt).toISOString(),
                ends_at: new Date(endsAt).toISOString(),
                timezone: 'Asia/Almaty',
                min_participants: Number(minParticipants) || 2,
                max_participants: Number(maxParticipants) || 2,
                pricing_model: pricingModel,
                price_total_minor: pricingModel === 'fixed_split' ? Number(priceTotal) : undefined,
                price_per_person_minor: pricingModel === 'per_person' ? Number(pricePerPerson) : undefined,
                currency: 'KZT',
                lock_before_minutes: 60,
                visibility: 'public',
              })
            }
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Input label={t('sessions.ruleName')} value={name} onChange={(e) => setName(e.currentTarget.value)} />
        <Select
          label={t('sessions.modeLabel')}
          value={mode}
          onChange={(e) => setMode(e.currentTarget.value as EditorMode)}
          options={[
            { value: 'scheduled', label: t('sessions.mode.scheduled') },
            { value: 'open', label: t('sessions.mode.open') },
          ]}
        />
        <Input label={t('sessions.startsAt')} type="datetime-local" value={startsAt} onChange={(e) => setStartsAt(e.currentTarget.value)} />
        <Input label={t('sessions.endsAt')} type="datetime-local" value={endsAt} onChange={(e) => setEndsAt(e.currentTarget.value)} />
        <Input label={t('sessions.minPlayers')} type="number" value={minParticipants} onChange={(e) => setMinParticipants(e.currentTarget.value)} />
        <Input label={t('sessions.maxPlayers')} type="number" value={maxParticipants} onChange={(e) => setMaxParticipants(e.currentTarget.value)} />
        <Select
          label={t('sessions.pricingModel')}
          value={pricingModel}
          onChange={(e) => setPricingModel(e.currentTarget.value as 'fixed_split' | 'per_person')}
          options={[
            { value: 'fixed_split', label: t('sessions.fixedSplit') },
            { value: 'per_person', label: t('sessions.perPerson') },
          ]}
        />
        {pricingModel === 'fixed_split' ? (
          <Input label={t('sessions.totalPrice')} type="number" value={priceTotal} onChange={(e) => setPriceTotal(e.currentTarget.value)} />
        ) : (
          <Input label={t('sessions.pricePerPerson')} type="number" value={pricePerPerson} onChange={(e) => setPricePerPerson(e.currentTarget.value)} />
        )}
      </div>
      <input type="hidden" value={resourceId} readOnly />
    </Modal>
  );
}
