import { BrowserRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom';

import { AppShell } from '@/components/layout/AppShell';
import { DashboardPage } from '@/pages/DashboardPage';
import { LoginPage } from '@/pages/LoginPage';
import { OwnersPage } from '@/pages/OwnersPage';
import { VenuesPage } from '@/pages/VenuesPage';
import { FacilityDetailPage } from '@/pages/FacilityDetailPage';
import { VenueRequestsPage } from '@/pages/VenueRequestsPage';
import { NotFoundPage } from '@/pages/NotFoundPage';
import { useAdminAuth } from '@/store/auth';
import { useApplyTheme } from '@/store/theme';

function AdminGuard() {
  const isAuth = useAdminAuth((s) => s.isAuthenticated);
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
        <Route element={<AdminGuard />}>
          <Route element={<AppShell />}>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/venues" element={<VenuesPage />} />
            <Route path="/venues/:facilityId" element={<FacilityDetailPage />} />
            <Route path="/owners" element={<OwnersPage />} />
            <Route path="/venue-requests" element={<VenueRequestsPage />} />
          </Route>
        </Route>
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}
