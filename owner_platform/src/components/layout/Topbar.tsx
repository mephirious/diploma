import { Link, useLocation } from 'react-router-dom';
import { ChevronRight, Menu, Search } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { LanguageMenu } from '@/components/common/LanguageMenu';
import { ThemeToggle } from '@/components/common/ThemeToggle';
import { cn } from '@/lib/cn';

type TopbarProps = {
  onMenuClick?: () => void;
};

export function Topbar({ onMenuClick }: TopbarProps) {
  const { t } = useTranslation();
  const location = useLocation();

  const crumbs = buildBreadcrumbs(location.pathname, t);

  return (
    <header
      className={cn(
        'sticky top-0 z-20 flex items-center gap-3 border-b',
        'border-black/5 dark:border-white/10',
        'bg-surface-light/85 dark:bg-surface-dark/85 backdrop-blur-xl',
        'px-4 md:px-8 h-16',
      )}
    >
      <button
        type="button"
        onClick={onMenuClick}
        aria-label={t('common.openMenu')}
        className="inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-lg text-text-light transition-colors hover:bg-black/[0.04] dark:text-text-dark dark:hover:bg-white/[0.06] md:hidden"
      >
        <Menu size={20} />
      </button>

      <span className="min-w-0 flex-1 truncate text-sm font-bold md:hidden">
        {crumbs[crumbs.length - 1]?.label}
      </span>

      <nav className="hidden md:flex items-center gap-1 text-sm text-muted-light dark:text-muted-dark min-w-0">
        {crumbs.map((c, i) => (
          <div key={`${c.to ?? c.label}-${i}`} className="flex items-center gap-1 min-w-0">
            {i > 0 ? <ChevronRight size={14} className="opacity-60" /> : null}
            {c.to ? (
              <Link
                to={c.to}
                className={cn(
                  'truncate max-w-[220px] hover:text-text-light dark:hover:text-text-dark transition-colors',
                  i === crumbs.length - 1 &&
                    'font-bold text-text-light dark:text-text-dark',
                )}
              >
                {c.label}
              </Link>
            ) : (
              <span
                className={cn(
                  'truncate max-w-[240px]',
                  i === crumbs.length - 1 &&
                    'font-bold text-text-light dark:text-text-dark',
                )}
              >
                {c.label}
              </span>
            )}
          </div>
        ))}
      </nav>

      <div className="ml-auto flex items-center gap-1">
        <div className="hidden lg:flex items-center h-10 w-72 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] px-3 text-muted-light dark:text-muted-dark">
          <Search size={16} className="mr-2" />
          <input
            placeholder={t('common.searchPlaceholder')}
            className="flex-1 bg-transparent outline-none text-sm text-text-light dark:text-text-dark placeholder:text-muted-light dark:placeholder:text-muted-dark"
          />
          <span className="ml-2 rounded border border-black/10 dark:border-white/15 px-1.5 py-0.5 text-[10px] font-mono">
            ⌘K
          </span>
        </div>
        <LanguageMenu />
        <ThemeToggle />
      </div>
    </header>
  );
}

function buildBreadcrumbs(path: string, t: (k: string) => string): Array<{ label: string; to?: string }> {
  const segments = path.split('/').filter(Boolean);
  if (segments.length === 0) return [{ label: t('nav.dashboard') }];

  const crumbs: Array<{ label: string; to?: string }> = [];
  let acc = '';
  for (let i = 0; i < segments.length; i++) {
    acc += '/' + segments[i];
    const seg = segments[i];
    let label = seg;
    if (seg === 'dashboard') label = t('nav.dashboard');
    else if (seg === 'facilities') label = t('nav.facilities');
    else if (seg === 'bookings') label = t('nav.bookings');
    else if (seg === 'analytics') label = t('nav.analytics');
    else if (seg === 'sessions') label = t('nav.sessions');
    else if (seg === 'chats') label = t('nav.chats');
    else if (seg === 'settings') label = t('nav.settings');
    else if (seg === 'resources' && i > 0) label = t('facilityDetail.resources');
    else if (seg === 'support') label = t('nav.support');
    else label = decodeURIComponent(seg);

    const isLast = i === segments.length - 1;
    crumbs.push({ label, to: isLast ? undefined : acc });
  }
  return crumbs;
}
