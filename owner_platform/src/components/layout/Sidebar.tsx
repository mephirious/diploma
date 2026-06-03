import { NavLink, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import {
  LayoutDashboard,
  Building2,
  CalendarClock,
  BarChart3,
  MessageCircle,
  MessageCircleQuestion,
  LogOut,
  UsersRound,
} from 'lucide-react';
import { useChatStore } from '@/store/chat';
import { useTranslation } from 'react-i18next';

import { Logo } from '@/components/common/Logo';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useAuth } from '@/store/auth';
import { cn } from '@/lib/cn';

type Item = { to: string; labelKey: string; icon: typeof LayoutDashboard; comingSoon?: boolean };

const overviewItems: Item[] = [
  { to: '/dashboard', labelKey: 'nav.dashboard', icon: LayoutDashboard },
  { to: '/analytics', labelKey: 'nav.analytics', icon: BarChart3 },
];

const venuesItems: Item[] = [
  { to: '/facilities', labelKey: 'nav.facilities', icon: Building2 },
  { to: '/bookings', labelKey: 'nav.bookings', icon: CalendarClock },
  { to: '/sessions', labelKey: 'nav.sessions', icon: UsersRound },
];

const supportItems: Item[] = [
  { to: '/chats', labelKey: 'nav.chats', icon: MessageCircle },
  { to: '/support', labelKey: 'nav.support', icon: MessageCircleQuestion, comingSoon: true },
];

export function Sidebar() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const logout = useAuth((s) => s.logout);
  const user = useAuth((s) => s.user);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const chatUnread = useChatStore((s) =>
    s.conversations.reduce((sum, c) => sum + c.unreadCount, 0),
  );

  function handleLogout() {
    logout();
    navigate('/login', { replace: true });
  }

  return (
    <aside
      className={cn(
        'hidden md:flex shrink-0 w-64 flex-col border-r',
        'border-black/5 dark:border-white/10',
        'bg-surface-light/80 dark:bg-surface-dark/80 backdrop-blur-xl',
      )}
    >
      <div className="px-5 pt-5 pb-3">
        <Logo />
      </div>

      <nav className="flex-1 px-3 py-3 space-y-6 overflow-y-auto">
        <SidebarSection items={overviewItems} titleKey="nav.groupOverview" />
        <SidebarSection items={venuesItems} titleKey="nav.groupVenues" />
        <SidebarSection
          items={supportItems}
          titleKey="nav.groupSupport"
          badgeByPath={{ '/chats': chatUnread }}
        />
      </nav>

      <div className="border-t border-black/5 dark:border-white/10 p-4">
        <div className="mb-3 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-brand-500 text-sm font-bold text-white">
            {user?.fullName?.[0] ?? '?'}
          </div>
          <div className="min-w-0">
            <div className="truncate text-sm font-bold text-text-light dark:text-text-dark">
              {user?.fullName ?? '—'}
            </div>
            <div className="truncate text-xs text-muted-light dark:text-muted-dark">
              {user?.email ?? ''}
            </div>
          </div>
        </div>
        <button
          type="button"
          onClick={() => setConfirmOpen(true)}
          className={cn(
            'flex w-full items-center gap-2 rounded-lg px-3 py-2.5 text-sm font-semibold',
            'text-muted-light hover:text-danger hover:bg-danger/10 transition-colors',
            'dark:text-muted-dark',
          )}
        >
          <LogOut size={16} />
          {t('common.logout')}
        </button>
      </div>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={handleLogout}
        title={t('common.logoutConfirmTitle')}
        description={t('common.logoutConfirmBody')}
        confirmLabel={t('common.logout')}
        cancelLabel={t('common.cancel')}
        tone="danger"
      />
    </aside>
  );
}

function SidebarSection({
  items,
  titleKey,
  badgeByPath,
}: {
  items: Item[];
  titleKey: string;
  badgeByPath?: Record<string, number>;
}) {
  const { t } = useTranslation();
  return (
    <div>
      <div className="mb-2 px-3 text-[11px] font-bold uppercase tracking-widest text-muted-light/80 dark:text-muted-dark/80 leading-snug">
        {t(titleKey)}
      </div>
      <ul className="space-y-1">
        {items.map((item) => {
          const Icon = item.icon;
          return (
            <li key={item.to}>
              <NavLink
                to={item.to}
                className={({ isActive }) =>
                  cn(
                    'group flex items-center gap-3 rounded-lg px-3 py-2.5 text-[14px] font-semibold transition-colors',
                    isActive
                      ? 'bg-brand-500/15 text-brand-700 dark:text-brand-200'
                      : 'text-muted-light hover:text-text-light hover:bg-black/[0.04] dark:text-muted-dark dark:hover:text-text-dark dark:hover:bg-white/[0.06]',
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <span
                      className={cn(
                        'flex h-8 w-8 items-center justify-center rounded-md transition-colors',
                        isActive
                          ? 'bg-brand-500 text-white'
                          : 'bg-transparent text-muted-light dark:text-muted-dark group-hover:text-text-light dark:group-hover:text-text-dark',
                      )}
                    >
                      <Icon size={16} />
                    </span>
                    <span className="flex-1 truncate">{t(item.labelKey)}</span>
                    {item.comingSoon ? (
                      <span className="rounded-full bg-black/5 px-2 py-0.5 text-[10px] font-bold uppercase text-muted-light dark:bg-white/10 dark:text-muted-dark">
                        {t('common.comingSoon')}
                      </span>
                    ) : (badgeByPath?.[item.to] ?? 0) > 0 ? (
                      <span className="min-w-[1.25rem] rounded-full bg-brand-500 px-1.5 py-0.5 text-center text-[10px] font-bold text-white">
                        {badgeByPath![item.to]! > 99 ? '99+' : badgeByPath![item.to]}
                      </span>
                    ) : null}
                  </>
                )}
              </NavLink>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
