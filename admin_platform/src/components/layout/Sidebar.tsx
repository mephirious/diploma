import { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
  Building2,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  UsersRound,
  X,
} from 'lucide-react';
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

type SidebarProps = {
  mobileOpen?: boolean;
  onMobileClose?: () => void;
};

export function Sidebar({ mobileOpen = false, onMobileClose }: SidebarProps) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const logout = useAdminAuth((s) => s.logout);
  const user = useAdminAuth((s) => s.user);
  const [confirmOpen, setConfirmOpen] = useState(false);

  function handleLogout() {
    logout();
    navigate('/login', { replace: true });
  }

  function handleNavClick() {
    onMobileClose?.();
  }

  const renderSidebarContent = (showCloseButton: boolean) => (
    <>
      <div className="flex items-center justify-between px-5 pb-3 pt-5">
        <Logo />
        {showCloseButton ? (
          <button
            type="button"
            onClick={onMobileClose}
            aria-label={t('common.closeMenu')}
            className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-muted-light transition-colors hover:bg-black/[0.04] hover:text-text-light dark:text-muted-dark dark:hover:bg-white/[0.06] dark:hover:text-text-dark"
          >
            <X size={18} />
          </button>
        ) : null}
      </div>

      <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-4">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              onClick={handleNavClick}
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
    </>
  );

  return (
    <>
      <aside className="hidden w-64 shrink-0 flex-col border-r border-black/5 bg-surface-light/85 backdrop-blur-xl dark:border-white/10 dark:bg-surface-dark/85 md:flex">
        {renderSidebarContent(false)}
      </aside>

      <div
        className={cn(
          'fixed inset-0 z-40 md:hidden',
          mobileOpen ? 'pointer-events-auto' : 'pointer-events-none',
        )}
        aria-hidden={!mobileOpen}
      >
        <button
          type="button"
          aria-label={t('common.closeMenu')}
          onClick={onMobileClose}
          className={cn(
            'absolute inset-0 bg-black/40 transition-opacity duration-300',
            mobileOpen ? 'opacity-100' : 'opacity-0',
          )}
        />
        <aside
          className={cn(
            'absolute inset-y-0 left-0 flex w-[min(18rem,calc(100vw-3rem))] flex-col border-r',
            'border-black/5 dark:border-white/10',
            'bg-surface-light dark:bg-surface-dark shadow-card-hover',
            'transition-transform duration-300 ease-out',
            mobileOpen ? 'translate-x-0' : '-translate-x-full',
          )}
        >
          {renderSidebarContent(true)}
        </aside>
      </div>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={handleLogout}
        title={t('common.logout')}
        description={t('common.logout')}
        confirmLabel={t('common.logout')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </>
  );
}
