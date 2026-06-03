import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CalendarX2, Plus, Pencil, Trash2 } from 'lucide-react';
import type { Blackout } from '@/types/schedule';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/EmptyState';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { Input, Textarea } from '@/components/ui/Input';

export function BlackoutEditor({
  resourceId,
  blackouts,
  onChange,
  onCreate,
  onUpdate,
  onDelete,
  busy = false,
}: {
  resourceId: string;
  blackouts: Blackout[];
  onChange: (next: Blackout[]) => void;
  onCreate?: (b: Blackout) => Promise<void>;
  onUpdate?: (b: Blackout) => Promise<void>;
  onDelete?: (b: Blackout) => Promise<void>;
  busy?: boolean;
}) {
  const { t, i18n } = useTranslation();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<Blackout | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<Blackout | null>(null);

  async function handleSave(b: Blackout) {
    const exists = blackouts.some((x) => x.id === b.id);
    if (exists && onUpdate) {
      await onUpdate(b);
      setEditorOpen(false);
      setEditing(null);
      return;
    }
    if (!exists && onCreate) {
      await onCreate(b);
      setEditorOpen(false);
      setEditing(null);
      return;
    }
    onChange(
      exists ? blackouts.map((x) => (x.id === b.id ? b : x)) : [...blackouts, b],
    );
    setEditorOpen(false);
    setEditing(null);
  }

  async function handleDelete(b: Blackout) {
    if (onDelete) {
      await onDelete(b);
      setConfirmDelete(null);
      return;
    }
    onChange(blackouts.filter((x) => x.id !== b.id));
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="text-base font-extrabold">
              {t('resource.blackoutTitle')}
            </h3>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark max-w-2xl">
              {t('resource.blackoutSubtitle')}
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
            {t('resource.addBlackout')}
          </Button>
        </div>
      </CardHeader>
      <CardBody>
        {blackouts.length === 0 ? (
          <EmptyState
            icon={<CalendarX2 size={20} />}
            title={t('resource.noBlackouts')}
            action={
              <Button
                size="sm"
                leftIcon={<Plus size={14} />}
                loading={busy}
                disabled={busy}
                onClick={() => setEditorOpen(true)}
              >
                {t('resource.addBlackout')}
              </Button>
            }
          />
        ) : (
          <ul className="space-y-2">
            {blackouts.map((b) => (
              <li
                key={b.id}
                className="flex items-center gap-3 rounded-lg border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] p-3"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-danger/15 text-danger">
                  <CalendarX2 size={18} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-sm font-bold">
                    {new Intl.DateTimeFormat(i18n.language, {
                      dateStyle: 'medium',
                      timeStyle: 'short',
                    }).format(new Date(b.start_at))}{' '}
                    –{' '}
                    {new Intl.DateTimeFormat(i18n.language, {
                      dateStyle: 'medium',
                      timeStyle: 'short',
                    }).format(new Date(b.end_at))}
                  </div>
                  <div className="text-xs text-muted-light dark:text-muted-dark">
                    {b.reason ?? '—'}
                  </div>
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  leftIcon={<Pencil size={14} />}
                  onClick={() => {
                    setEditing(b);
                    setEditorOpen(true);
                  }}
                >
                  {t('common.edit')}
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  leftIcon={<Trash2 size={14} />}
                  onClick={() => setConfirmDelete(b)}
                >
                  {t('common.delete')}
                </Button>
              </li>
            ))}
          </ul>
        )}
      </CardBody>

      {editorOpen ? (
        <BlackoutModal
          resourceId={resourceId}
          initial={editing}
          onClose={() => {
            setEditorOpen(false);
            setEditing(null);
          }}
          onSave={(item) => {
            void handleSave(item);
          }}
        />
      ) : null}

      <ConfirmDialog
        open={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => {
          if (confirmDelete) void handleDelete(confirmDelete);
        }}
        title={t('resource.deleteBlackoutConfirm')}
        confirmLabel={t('common.delete')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </Card>
  );
}

function toInputValue(iso: string): string {
  // "YYYY-MM-DDTHH:mm" for <input type="datetime-local">
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function fromInputValue(local: string): string {
  if (!local) return new Date().toISOString();
  const d = new Date(local);
  return Number.isNaN(d.getTime()) ? new Date().toISOString() : d.toISOString();
}

function BlackoutModal({
  resourceId,
  initial,
  onClose,
  onSave,
}: {
  resourceId: string;
  initial: Blackout | null;
  onClose: () => void;
  onSave: (b: Blackout) => void;
}) {
  const { t } = useTranslation();
  const [start, setStart] = useState(toInputValue(initial?.start_at ?? new Date().toISOString()));
  const [end, setEnd] = useState(toInputValue(initial?.end_at ?? new Date(Date.now() + 3600 * 1000).toISOString()));
  const [reason, setReason] = useState(initial?.reason ?? '');

  return (
    <Modal
      open
      onClose={onClose}
      title={initial ? t('common.edit') : t('resource.addBlackout')}
      footer={
        <>
          <Button variant="ghost" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button
            onClick={() =>
              onSave({
                id: initial?.id ?? `${resourceId}-bo-${Date.now()}`,
                resource_id: resourceId,
                start_at: fromInputValue(start),
                end_at: fromInputValue(end),
                status: initial?.status ?? 'active',
                reason: reason.trim() || undefined,
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
          label={t('resource.startAt')}
          type="datetime-local"
          value={start}
          onChange={(e) => setStart(e.currentTarget.value)}
        />
        <Input
          label={t('resource.endAt')}
          type="datetime-local"
          value={end}
          onChange={(e) => setEnd(e.currentTarget.value)}
        />
        <Textarea
          className="md:col-span-2"
          label={t('resource.reason')}
          rows={3}
          value={reason}
          onChange={(e) => setReason(e.currentTarget.value)}
          placeholder="Cleaning, private event, renovation…"
        />
      </div>
    </Modal>
  );
}
