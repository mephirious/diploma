import { useState, useRef, useEffect } from 'react';
import { Monitor, Moon, Sun } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useTheme, type ThemeMode } from '@/store/theme';
import { cn } from '@/lib/cn';

const items: Array<{ id: ThemeMode; icon: typeof Sun; labelKey: string }> = [
  { id: 'light', icon: Sun, labelKey: 'common.themeLight' },
  { id: 'dark', icon: Moon, labelKey: 'common.themeDark' },
  { id: 'system', icon: Monitor, labelKey: 'common.themeSystem' },
];

export function ThemeToggle() {
  const { t } = useTranslation();
  const mode = useTheme((s) => s.mode);
  const setMode = useTheme((s) => s.setMode);
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!open) return;
    function onDoc(e: MouseEvent) {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onDoc);
    return () => document.removeEventListener('mousedown', onDoc);
  }, [open]);

  const Current = items.find((i) => i.id === mode)?.icon ?? Monitor;

  return (
    <div ref={rootRef} className="relative">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-label={t('common.theme')}
        className={cn(
          'inline-flex h-10 w-10 items-center justify-center rounded-lg transition-colors focus-ring',
          'text-muted-light hover:text-text-light hover:bg-black/5 dark:text-muted-dark dark:hover:text-text-dark dark:hover:bg-white/10',
        )}
      >
        <Current size={18} />
      </button>
      {open ? (
        <div
          className={cn(
            'absolute right-0 mt-2 w-44 rounded-lg p-1 shadow-card-hover z-40',
            'bg-surface-light dark:bg-surface-dark border border-black/5 dark:border-white/10 animate-fade-in',
          )}
        >
          <div className="px-3 py-2 text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
            {t('common.theme')}
          </div>
          {items.map((it) => {
            const Icon = it.icon;
            const active = mode === it.id;
            return (
              <button
                key={it.id}
                type="button"
                onClick={() => {
                  setMode(it.id);
                  setOpen(false);
                }}
                className={cn(
                  'flex w-full items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors',
                  active
                    ? 'bg-brand-500/15 text-brand-700 dark:text-brand-300 font-semibold'
                    : 'hover:bg-black/5 dark:hover:bg-white/10 text-text-light dark:text-text-dark',
                )}
              >
                <Icon size={16} />
                {t(it.labelKey)}
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}
