import { Link, useLocation } from 'react-router-dom';
import { ChevronRight, Menu } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { LanguageMenu } from '@/components/common/LanguageMenu';
import { ThemeToggle } from '@/components/common/ThemeToggle';

type TopbarProps = {
  onMenuClick?: () => void;
};

export function Topbar({ onMenuClick }: TopbarProps) {
  const { t } = useTranslation();
  const location = useLocation();
  const label = routeLabel(location.pathname, t);

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center gap-3 border-b border-black/5 bg-surface-light/85 px-4 backdrop-blur-xl dark:border-white/10 dark:bg-surface-dark/85 md:px-8">
      <button
        type="button"
        onClick={onMenuClick}
        aria-label={t('common.openMenu')}
        className="inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-lg text-text-light transition-colors hover:bg-black/[0.04] dark:text-text-dark dark:hover:bg-white/[0.06] md:hidden"
      >
        <Menu size={20} />
      </button>

      <span className="min-w-0 flex-1 truncate text-sm font-bold md:hidden">{label}</span>

      <nav className="hidden min-w-0 items-center gap-1 text-sm text-muted-light dark:text-muted-dark md:flex">
        <Link to="/dashboard" className="truncate hover:text-text-light dark:hover:text-text-dark">
          {t('nav.dashboard')}
        </Link>
        {location.pathname !== '/dashboard' ? (
          <>
            <ChevronRight size={14} className="opacity-60" />
            <span className="truncate font-bold text-text-light dark:text-text-dark">{label}</span>
          </>
        ) : null}
      </nav>

      <div className="ml-auto flex items-center gap-1">
        <LanguageMenu />
        <ThemeToggle />
      </div>
    </header>
  );
}

function routeLabel(path: string, t: (key: string) => string) {
  if (path.startsWith('/venues')) return t('nav.venues');
  if (path.startsWith('/owners')) return t('nav.owners');
  if (path.startsWith('/venue-requests')) return t('nav.venueRequests');
  return t('nav.dashboard');
}
