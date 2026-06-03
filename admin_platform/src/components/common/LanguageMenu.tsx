import { useEffect, useRef, useState } from 'react';
import { Globe, Check } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import {
  SUPPORTED_LOCALES,
  currentLocale,
  localeLabels,
  setAppLocale,
  type Locale,
} from '@/i18n';
import { cn } from '@/lib/cn';

export function LanguageMenu() {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState<Locale>(currentLocale());
  const rootRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    setActive(currentLocale());
  }, [open]);

  useEffect(() => {
    if (!open) return;
    function onDoc(e: MouseEvent) {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onDoc);
    return () => document.removeEventListener('mousedown', onDoc);
  }, [open]);

  return (
    <div ref={rootRef} className="relative">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-label={t('common.language')}
        className={cn(
          'inline-flex h-10 items-center gap-2 rounded-lg px-3 transition-colors focus-ring',
          'text-muted-light hover:text-text-light hover:bg-black/5 dark:text-muted-dark dark:hover:text-text-dark dark:hover:bg-white/10',
        )}
      >
        <Globe size={18} />
        <span className="text-sm font-semibold uppercase tracking-wide">
          {active}
        </span>
      </button>

      {open ? (
        <div
          className={cn(
            'absolute right-0 mt-2 w-48 rounded-lg p-1 shadow-card-hover z-40',
            'bg-surface-light dark:bg-surface-dark border border-black/5 dark:border-white/10 animate-fade-in',
          )}
        >
          <div className="px-3 py-2 text-[11px] font-bold uppercase tracking-widest text-muted-light dark:text-muted-dark">
            {t('common.language')}
          </div>
          {SUPPORTED_LOCALES.map((code) => {
            const selected = active === code;
            return (
              <button
                key={code}
                type="button"
                onClick={() => {
                  setAppLocale(code);
                  setActive(code);
                  setOpen(false);
                }}
                className={cn(
                  'flex w-full items-center justify-between gap-2 rounded-md px-3 py-2 text-sm transition-colors',
                  selected
                    ? 'bg-brand-500/15 text-brand-700 dark:text-brand-300 font-semibold'
                    : 'hover:bg-black/5 dark:hover:bg-white/10 text-text-light dark:text-text-dark',
                )}
              >
                <span>{localeLabels[code]}</span>
                {selected ? <Check size={16} /> : null}
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}
