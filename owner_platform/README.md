# ZhamSpace — Owner Platform

The web dashboard for sport facility **owners** in the ZhamSpace ecosystem. This is the second client of the platform (alongside the Flutter customer app in `frontend/`) and serves the owner role described in the project spec: manage facilities, resources, schedules, pricing, and blackouts.

The UI intentionally mirrors the mobile app's **design tokens, colors, radii, and elements**, so the two surfaces feel like one product.

## Tech stack

- **Vite** + **React 18** + **TypeScript** (strict)
- **Tailwind CSS** with design tokens ported from `frontend/lib/core/theme/app_colors.dart`
- **React Router v6** for routing (protected `AppShell` route)
- **Zustand** for small global state (auth, theme)
- **i18next + react-i18next** for the three supported locales: `en`, `ru`, `kk`
- **recharts** for the dashboard revenue chart
- **lucide-react** for icons

## Getting started

```bash
cd owner_platform
npm install
npm run dev        # starts Vite on http://localhost:5173
```

Other scripts:

- `npm run build` — type-check + production build
- `npm run preview` — preview production build locally
- `npm run typecheck` — TS project check only

## Project layout

```text
src/
  main.tsx                   # entry
  App.tsx                    # router (BrowserRouter, AppShell gate)
  index.css                  # Tailwind + base styles
  i18n/                      # en.ts, ru.ts, kk.ts + init
  lib/                       # cn.ts, format.ts
  store/                     # auth.ts, theme.ts
  types/                     # venue.ts, resource.ts, pricing.ts, schedule.ts, booking.ts
  mock/                      # MOCK_VENUES, schedule results, dashboard data
  components/
    layout/                  # AppShell, Sidebar, Topbar
    ui/                      # Button, Card, Badge, Input, Select, Textarea, Modal, Tabs, IconButton, EmptyState, ConfirmDialog
    common/                  # Logo, LanguageMenu, ThemeToggle, PageHeader, StatusChip
    dashboard/               # StatCard, RevenueChart, OccupancyHeatmap
    resource/                # WeeklyScheduleEditor, PricingEditor, BlackoutEditor, SlotPreview
  pages/
    LoginPage.tsx            # mock owner login + "List your facility" contact modal
    DashboardPage.tsx        # KPI cards + revenue chart + incoming bookings
    FacilitiesPage.tsx       # list of facilities (grid / list views)
    FacilityDetailPage.tsx   # info, images, contacts, resources
    ResourceDetailPage.tsx   # overview + schedules/pricing/blackouts tabs + slot preview
    ComingSoonPage.tsx       # placeholder for non-MVP sections
```

## Data model parity with the mobile app

All data types in `src/types/` match the JSON shape the Go backend returns
and the Flutter frontend already consumes (`fromApiJson` in
`frontend/lib/features/venues/data/models/*.dart`). This means when the
real backend comes online, wiring is a field-for-field mapping:

- `Venue` ↔ `VenueModel.fromApiJson`
- `Resource` ↔ `ResourceModel`
- `PricingRule` ↔ `PricingRuleModel`
- `ResourceScheduleEntry` ↔ `ResourceScheduleEntryModel`
- `Blackout` ↔ `BlackoutModel`
- `ScheduleResultGroup` / `VenueScheduleResult` ↔ `ScheduleResultGroup` /
  `VenueScheduleResultModel`

All keys stay `snake_case` (matching the backend), so the mock data in
`src/mock/scheduleResults.ts` can be used directly in tests/snapshots once the
API is live.

## Design tokens

The color palette and radii are taken verbatim from the mobile theme:

| Token | Value | Mobile counterpart |
| --- | --- | --- |
| `brand-500` | `#00BFA5` | `AppColors.colorMain` |
| `brand-800` | `#1B5E4B` | `AppColors.colorSecondary` |
| `accent` | `#00E5CC` | `AppColors.colorAccent` |
| `bg-light` | `#F5F7FA` | `AppColors.lightBackground` |
| `bg-dark` | `#0F1923` | `AppColors.darkBackground` |
| `surface-light` | `#FFFFFF` | `AppColors.lightSurface` |
| `surface-dark` | `#1A2737` | `AppColors.darkSurface` |
| `rounded-sm/md/lg/xl` | 8/12/16/24 | `AppRadii.*` |

Dark mode is toggled via the `dark` class on `<html>` (`useApplyTheme` in
`store/theme.ts`). The ThemeToggle in the topbar supports light / dark /
system.

## Mock "login" flow

- The login screen accepts any credentials; clicking **Sign in** flips
  the Zustand auth store to authenticated and routes to `/dashboard`.
- The **"List your facility with us"** button opens a contact form with
  name, email, phone, business name, primary sport, city, and free-form
  message. Submitting the form shows a success state (no network call).
- **Log out** is available at the bottom of the sidebar — it clears the
  auth store and navigates back to `/login`.
