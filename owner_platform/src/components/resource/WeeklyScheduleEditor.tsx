import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Plus, Trash2, Clock } from 'lucide-react';
import type { ResourceScheduleEntry } from '@/types/schedule';
import { Button } from '@/components/ui/Button';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { Input, Select } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { shortTime, WEEKDAY_KEYS } from '@/lib/format';

export function WeeklyScheduleEditor({
  resourceId,
  entries,
  onChange,
}: {
  resourceId: string;
  entries: ResourceScheduleEntry[];
  onChange: (next: ResourceScheduleEntry[]) => void;
}) {
  const { t } = useTranslation();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<ResourceScheduleEntry | null>(null);
  const [confirmDelete, setConfirmDelete] =
    useState<ResourceScheduleEntry | null>(null);

  const byDay = new Map<number, ResourceScheduleEntry[]>();
  for (let d = 0; d < 7; d++) byDay.set(d, []);
  for (const e of entries) {
    byDay.get(e.day_of_week)?.push(e);
  }

  function handleSave(entry: ResourceScheduleEntry) {
    const exists = entries.some((e) => e.id === entry.id);
    const next = exists
      ? entries.map((e) => (e.id === entry.id ? entry : e))
      : [...entries, entry];
    onChange(next);
    setEditorOpen(false);
    setEditing(null);
  }

  function handleDelete(entry: ResourceScheduleEntry) {
    onChange(entries.filter((e) => e.id !== entry.id));
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="text-base font-extrabold">
              {t('resource.weeklyTitle')}
            </h3>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark max-w-2xl">
              {t('resource.weeklySubtitle')}
            </p>
          </div>
          <Button
            size="sm"
            leftIcon={<Plus size={14} />}
            onClick={() => {
              setEditing(null);
              setEditorOpen(true);
            }}
          >
            {t('resource.addSchedule')}
          </Button>
        </div>
      </CardHeader>
      <CardBody>
        {entries.length === 0 ? (
          <EmptyState
            icon={<Clock size={20} />}
            title={t('resource.noSchedule')}
            action={
              <Button
                size="sm"
                leftIcon={<Plus size={14} />}
                onClick={() => setEditorOpen(true)}
              >
                {t('resource.addSchedule')}
              </Button>
            }
          />
        ) : (
          <div className="grid gap-2.5 md:grid-cols-2">
            {WEEKDAY_KEYS.map((k, idx) => {
              const items = byDay.get(idx) ?? [];
              return (
                <div
                  key={k}
                  className="flex items-center gap-3 rounded-lg border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] px-3 py-2.5"
                >
                  <div className="w-16 text-[12px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
                    {t(`resource.weekdays.${k}`)}
                  </div>
                  <div className="flex flex-1 flex-wrap gap-1.5">
                    {items.length === 0 ? (
                      <span className="text-xs italic text-muted-light dark:text-muted-dark">
                        {t('common.none')}
                      </span>
                    ) : (
                      items.map((e) => (
                        <button
                          key={e.id}
                          type="button"
                          onClick={() => {
                            setEditing(e);
                            setEditorOpen(true);
                          }}
                          className="group inline-flex items-center gap-1.5 rounded-md bg-brand-500/15 px-2.5 py-1 text-xs font-bold text-brand-700 transition-colors hover:bg-brand-500/25 dark:text-brand-300"
                        >
                          <Clock size={12} />
                          {shortTime(e.start_time)} – {shortTime(e.end_time)}
                          <Trash2
                            size={12}
                            className="opacity-0 transition-opacity group-hover:opacity-100"
                            onClick={(ev) => {
                              ev.stopPropagation();
                              setConfirmDelete(e);
                            }}
                          />
                        </button>
                      ))
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </CardBody>

      {editorOpen ? (
        <ScheduleEntryModal
          resourceId={resourceId}
          initial={editing}
          onClose={() => {
            setEditorOpen(false);
            setEditing(null);
          }}
          onSave={handleSave}
          onDelete={
            editing
              ? () => {
                  setConfirmDelete(editing);
                  setEditorOpen(false);
                }
              : undefined
          }
        />
      ) : null}

      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => confirmDelete && handleDelete(confirmDelete)}
        title={t('resource.deleteScheduleConfirm')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </Card>
  );
}

function ScheduleEntryModal({
  initial,
  resourceId,
  onClose,
  onSave,
  onDelete,
}: {
  resourceId: string;
  initial: ResourceScheduleEntry | null;
  onClose: () => void;
  onSave: (entry: ResourceScheduleEntry) => void;
  onDelete?: () => void;
}) {
  const { t } = useTranslation();
  const [day, setDay] = useState(initial?.day_of_week ?? 1);
  const [start, setStart] = useState(
    shortTime(initial?.start_time) || '09:00',
  );
  const [end, setEnd] = useState(shortTime(initial?.end_time) || '22:00');
  const [status, setStatus] = useState<'active' | 'inactive'>(
    initial?.status ?? 'active',
  );

  return (
    <Modal
      open
      onClose={onClose}
      title={
        initial ? t('common.edit') + ' · ' + t('resource.weeklyTitle') : t('resource.addSchedule')
      }
      footer={
        <>
          {onDelete ? (
            <Button variant="danger" onClick={onDelete}>
              <Trash2 size={14} /> {t('common.delete')}
            </Button>
          ) : null}
          <Button variant="ghost" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button
            onClick={() => {
              onSave({
                id: initial?.id ?? `${resourceId}-sch-${Date.now()}`,
                resource_id: resourceId,
                day_of_week: day,
                start_time: `${start}:00`,
                end_time: `${end}:00`,
                timezone: initial?.timezone ?? 'Asia/Almaty',
                status,
              });
            }}
          >
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Select
          label={t('resource.dayOfWeek')}
          value={String(day)}
          onChange={(e) => setDay(Number(e.currentTarget.value))}
          options={WEEKDAY_KEYS.map((k, i) => ({
            value: String(i),
            label: t(`resource.weekdaysLong.${k}`),
          }))}
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
        <Input
          label={t('resource.startTime')}
          type="time"
          value={start}
          onChange={(e) => setStart(e.currentTarget.value)}
        />
        <Input
          label={t('resource.endTime')}
          type="time"
          value={end}
          onChange={(e) => setEnd(e.currentTarget.value)}
        />
        <div className="md:col-span-2">
          <Badge tone="muted">
            {t('resource.startAt')}: {start} · {t('resource.endAt')}: {end}
          </Badge>
        </div>
      </div>
    </Modal>
  );
}
