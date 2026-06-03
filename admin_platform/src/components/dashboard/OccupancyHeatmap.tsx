import { useTranslation } from 'react-i18next';
import { MOCK_OCCUPANCY_HEATMAP } from '@/mock/dashboard';

const BANDS = ['morning', 'noon', 'afternoon', 'evening', 'night'] as const;
const BAND_LABELS: Record<(typeof BANDS)[number], string> = {
  morning: '06–10',
  noon: '10–13',
  afternoon: '13–17',
  evening: '17–21',
  night: '21–23',
};

function toneFor(value: number): string {
  if (value > 0.9) return 'bg-brand-700 text-white';
  if (value > 0.75) return 'bg-brand-600 text-white';
  if (value > 0.6) return 'bg-brand-500 text-white';
  if (value > 0.45) return 'bg-brand-400 text-white';
  if (value > 0.3) return 'bg-brand-300 text-brand-900';
  if (value > 0.15) return 'bg-brand-200 text-brand-900';
  return 'bg-brand-100 text-brand-900';
}

export function OccupancyHeatmap() {
  const { t } = useTranslation();

  return (
    <div>
      <div className="grid grid-cols-[auto_repeat(5,1fr)] gap-2 text-xs">
        <div />
        {BANDS.map((b) => (
          <div
            key={b}
            className="text-center font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark text-[10px]"
          >
            {BAND_LABELS[b]}
          </div>
        ))}
        {MOCK_OCCUPANCY_HEATMAP.map((row) => (
          <RowSlot key={row.day} row={row} />
        ))}
      </div>
      <p className="mt-4 text-xs text-muted-light dark:text-muted-dark">
        {t('resource.slotsPreviewHint')}
      </p>
    </div>
  );
}

function RowSlot({ row }: { row: (typeof MOCK_OCCUPANCY_HEATMAP)[number] }) {
  return (
    <>
      <div className="flex items-center pr-2 text-xs font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark text-[10px]">
        {row.day}
      </div>
      {BANDS.map((band) => {
        const value = row[band];
        return (
          <div
            key={`${row.day}-${band}`}
            className={`flex h-10 items-center justify-center rounded-md font-semibold ${toneFor(value)}`}
            title={`${row.day} ${BAND_LABELS[band]} · ${Math.round(value * 100)}%`}
          >
            <span className="text-[11px]">{Math.round(value * 100)}%</span>
          </div>
        );
      })}
    </>
  );
}
