import { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { Building2, ClipboardList, LayoutDashboard, LogOut, UsersRound } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { Logo } from '@/components/common/Logo';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useAdminAuth } from '@/store/auth';
import { cn } from '@/lib/cn';

const navItems = [
  { to: '/dashboard', labelKey: 'nav.dashboard', icon: LayoutDashboard },
  { to: '/venues', labelKey: 'nav.venues', icon: Building2 },
  { to: '/owners', labelKey: 'nav.owners', icon: UsersRound },
  { to: '/venue-requests', labelKey: 'nav.venueRequests', icon: ClipboardList },
];

export function Sidebar() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const logout = useAdminAuth((s) => s.logout);
  const user = useAdminAuth((s) => s.user);
  const [confirmOpen, setConfirmOpen] = useState(false);

  function handleLogout() {
    logout();
    navigate('/login', { replace: true });
  }

  return (
    <aside className="hidden w-64 shrink-0 flex-col border-r border-black/5 bg-surface-light/85 backdrop-blur-xl dark:border-white/10 dark:bg-surface-dark/85 md:flex">
      <div className="px-5 pb-3 pt-5">
        <Logo />
      </div>

      <nav className="flex-1 space-y-1 px-3 py-4">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                cn(
                  'group flex items-center gap-3 rounded-lg px-3 py-2.5 text-[14px] font-semibold transition-colors',
                  isActive
                    ? 'bg-admin-500/15 text-admin-700 dark:text-admin-200'
                    : 'text-muted-light hover:bg-black/[0.04] hover:text-text-light dark:text-muted-dark dark:hover:bg-white/[0.06] dark:hover:text-text-dark',
                )
              }
            >
              {({ isActive }) => (
                <>
                  <span
                    className={cn(
                      'flex h-8 w-8 items-center justify-center rounded-md transition-colors',
                      isActive
                        ? 'bg-admin-500 text-white'
                        : 'text-muted-light dark:text-muted-dark',
                    )}
                  >
                    <Icon size={16} />
                  </span>
                  <span className="truncate">{t(item.labelKey)}</span>
                </>
              )}
            </NavLink>
          );
        })}
      </nav>

      <div className="border-t border-black/5 p-4 dark:border-white/10">
        <div className="mb-3 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-admin-500 text-sm font-bold text-white">
            {user?.fullName?.[0] ?? user?.username?.[0] ?? '?'}
          </div>
          <div className="min-w-0">
            <div className="truncate text-sm font-bold">{user?.fullName ?? 'Admin'}</div>
            <div className="truncate text-xs text-muted-light dark:text-muted-dark">
              {user?.email ?? ''}
            </div>
          </div>
        </div>
        <button
          type="button"
          onClick={() => setConfirmOpen(true)}
          className="flex w-full items-center gap-2 rounded-lg px-3 py-2.5 text-sm font-semibold text-muted-light transition-colors hover:bg-danger/10 hover:text-danger dark:text-muted-dark"
        >
          <LogOut size={16} />
          {t('common.logout')}
        </button>
      </div>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={handleLogout}
        title={t('common.logout')}
        description={t('common.logout')}
        confirmLabel={t('common.logout')}
        cancelLabel="Cancel"
        tone="danger"
      />
    </aside>
  );
}
