import { useTranslation } from 'react-i18next';
import type { ResourceScheduleEntry, Blackout } from '@/types/schedule';
import type { PricingRule } from '@/types/pricing';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { timeToHour, WEEKDAY_KEYS } from '@/lib/format';
import { formatPriceString } from '@/lib/format';

type SlotState = 'closed' | 'open' | 'override' | 'blocked';

type Cell = {
  state: SlotState;
  priceLabel?: string;
};

/** Build a 7×24 matrix of slot states using the same semantics as the mobile app. */
function buildMatrix(
  schedules: ResourceScheduleEntry[],
  pricing: PricingRule[],
  blackouts: Blackout[],
): Cell[][] {
  const matrix: Cell[][] = [];
  for (let dow = 0; dow < 7; dow++) {
    const row: Cell[] = [];
    const activeSchedule = schedules.find(
      (s) => s.day_of_week === dow && s.status === 'active',
    );
    const openStart = activeSchedule ? timeToHour(activeSchedule.start_time) : 0;
    const openEnd = activeSchedule ? timeToHour(activeSchedule.end_time) : 0;

    const overrides = pricing
      .filter(
        (r) =>
          r.status === 'active' &&
          (r.day_of_week === null || r.day_of_week === dow) &&
          r.priority > 0,
      )
      .sort((a, b) => b.priority - a.priority);

    for (let hour = 0; hour < 24; hour++) {
      if (!activeSchedule || hour < openStart || hour >= openEnd) {
        row.push({ state: 'closed' });
        continue;
      }

      // Day-of-week specific blackouts are UTC; approximate using local date compare.
      const blocked = blackouts.some((b) => {
        if (b.status !== 'active') return false;
        const start = new Date(b.start_at);
        const end = new Date(b.end_at);
        const startDow = start.getDay();
        const endDow = end.getDay();
        // Simple check: if blackout touches this dow & this hour overlap.
        const startHour = start.getHours();
        const endHour = end.getHours();
        if (startDow === dow) {
          return hour >= startHour && hour < (endDow === dow ? endHour : 24);
        }
        if (endDow === dow) {
          return hour < endHour;
        }
        return false;
      });
      if (blocked) {
        row.push({ state: 'blocked' });
        continue;
      }

      // Check for active override pricing.
      const override = overrides.find((r) => {
        if (r.start_time == null || r.end_time == null) {
          // Whole day with priority — counts as override for visualization.
          return true;
        }
        const sh = timeToHour(r.start_time);
        const eh = timeToHour(r.end_time);
        return hour >= sh && hour < eh;
      });

      if (override) {
        row.push({
          state: 'override',
          priceLabel: formatPriceString(override.price, override.currency),
        });
      } else {
        row.push({ state: 'open' });
      }
    }
    matrix.push(row);
  }
  return matrix;
}

const STATE_CLASS: Record<SlotState, string> = {
  closed: 'bg-black/[0.04] dark:bg-white/[0.04]',
  open: 'bg-success/70 dark:bg-success/60',
  override: 'bg-warning dark:bg-warning',
  blocked: 'bg-danger/80 dark:bg-danger/70',
};

const STATE_HINT: Record<SlotState, string> = {
  closed: 'Closed',
  open: 'Open',
  override: 'Pricing override',
  blocked: 'Blackout',
};

export function SlotPreview({
  schedules,
  pricing,
  blackouts,
}: {
  schedules: ResourceScheduleEntry[];
  pricing: PricingRule[];
  blackouts: Blackout[];
}) {
  const { t } = useTranslation();
  const matrix = buildMatrix(schedules, pricing, blackouts);

  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="text-base font-extrabold">
              {t('resource.slotsPreview')}
            </h3>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark max-w-2xl">
              {t('resource.slotsPreviewHint')}
            </p>
          </div>
          <div className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest">
            <LegendSwatch color="bg-success/70" label="Open" />
            <LegendSwatch color="bg-warning" label="Override" />
            <LegendSwatch color="bg-danger/80" label="Blackout" />
          </div>
        </div>
      </CardHeader>
      <CardBody>
        <div className="min-w-[640px] overflow-x-auto">
          <div className="grid grid-cols-[auto_repeat(24,minmax(18px,1fr))] gap-0.5 text-[10px]">
            <div />
            {Array.from({ length: 24 }, (_, h) => (
              <div
                key={h}
                className="text-center font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark"
              >
                {h % 2 === 0 ? h.toString().padStart(2, '0') : ''}
              </div>
            ))}

            {matrix.map((row, dow) => (
              <RowLine key={dow} dow={dow} row={row} />
            ))}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}

function LegendSwatch({ color, label }: { color: string; label: string }) {
  return (
    <span className="inline-flex items-center gap-1.5">
      <span className={`h-2 w-3 rounded-sm ${color}`} />
      {label}
    </span>
  );
}

function RowLine({ dow, row }: { dow: number; row: Cell[] }) {
  const { t } = useTranslation();
  return (
    <>
      <div className="pr-2 text-right text-[10px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
        {t(`resource.weekdays.${WEEKDAY_KEYS[dow]}`)}
      </div>
      {row.map((cell, hour) => (
        <div
          key={`${dow}-${hour}`}
          className={`h-5 rounded-sm ${STATE_CLASS[cell.state]}`}
          title={`${t(`resource.weekdaysLong.${WEEKDAY_KEYS[dow]}`)} ${hour.toString().padStart(2, '0')}:00 · ${STATE_HINT[cell.state]}${cell.priceLabel ? ` · ${cell.priceLabel}` : ''}`}
        />
      ))}
    </>
  );
}
