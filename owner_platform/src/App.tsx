import { BrowserRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom';

import { AppShell } from '@/components/layout/AppShell';
import { LoginPage } from '@/pages/LoginPage';
import { DashboardPage } from '@/pages/DashboardPage';
import { FacilitiesPage } from '@/pages/FacilitiesPage';
import { FacilityDetailPage } from '@/pages/FacilityDetailPage';
import { ResourceDetailPage } from '@/pages/ResourceDetailPage';
import { ComingSoonPage } from '@/pages/ComingSoonPage';
import { BookingsPage } from '@/pages/BookingsPage';
import { RevenuePage } from '@/pages/RevenuePage';
import { ChatsPage } from '@/pages/ChatsPage';
import { NotFoundPage } from '@/pages/NotFoundPage';
import { useApplyTheme } from '@/store/theme';
import { useAuth } from '@/store/auth';

function OwnerGuard() {
  const isAuth = useAuth((s) => s.isAuthenticated);
  const location = useLocation();
  if (!isAuth) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  return <Outlet />;
}

export function App() {
  useApplyTheme();

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route element={<OwnerGuard />}>
          <Route element={<AppShell />}>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/facilities" element={<FacilitiesPage />} />
            <Route path="/facilities/:facilityId" element={<FacilityDetailPage />} />
            <Route
              path="/facilities/:facilityId/resources/:resourceId"
              element={<ResourceDetailPage />}
            />
            <Route path="/bookings" element={<BookingsPage />} />
            <Route path="/analytics" element={<RevenuePage />} />
            <Route path="/settings" element={<ComingSoonPage titleKey="nav.settings" />} />
            <Route path="/chats" element={<ChatsPage />} />
            <Route path="/support" element={<ComingSoonPage titleKey="nav.support" />} />
          </Route>
        </Route>

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}
