import { useState, type FormEvent } from 'react';
import { Navigate, useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  Lock,
  Mail,
  Eye,
  EyeOff,
  Sparkles,
  Building2,
  LineChart,
  CalendarClock,
  Smartphone,
  Download,
} from 'lucide-react';

import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { Logo } from '@/components/common/Logo';
import { LanguageMenu } from '@/components/common/LanguageMenu';
import { ThemeToggle } from '@/components/common/ThemeToggle';
import { useAuth } from '@/store/auth';
import { cn } from '@/lib/cn';

const APP_STORE_URL = import.meta.env.VITE_APP_STORE_URL as string | undefined;
const PLAY_STORE_URL = import.meta.env.VITE_PLAY_STORE_URL as string | undefined;

export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const isAuthenticated = useAuth((s) => s.isAuthenticated);
  const login = useAuth((s) => s.login);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);
  const [listFacilityOpen, setListFacilityOpen] = useState(false);

  if (isAuthenticated) {
    const from =
      (location.state as { from?: { pathname?: string } } | null)?.from?.pathname ??
      '/dashboard';
    return <Navigate to={from} replace />;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setLoginError(null);
    try {
      await login({ username: email.trim(), password });
      navigate('/dashboard', { replace: true });
    } catch {
      setLoginError(t('auth.invalidCredentials'));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative min-h-screen bg-bg-light dark:bg-bg-dark text-text-light dark:text-text-dark overflow-hidden">
      <BackgroundBlobs />

      <header className="relative flex items-center justify-between px-6 md:px-10 py-5">
        <Logo />
        <div className="flex items-center gap-1">
          <LanguageMenu />
          <ThemeToggle />
        </div>
      </header>

      <main className="relative mx-auto grid max-w-7xl gap-10 px-6 md:px-10 py-6 md:grid-cols-2 md:items-center md:py-10">
        <section className="hidden md:flex flex-col gap-6">
          <div className="inline-flex w-fit items-center gap-2 rounded-full bg-brand-500/12 px-3 py-1.5 text-[12px] font-bold uppercase tracking-widest text-brand-700 dark:text-brand-300">
            <Sparkles size={14} /> {t('app.tagline')}
          </div>
          <h1 className="text-4xl font-extrabold leading-tight md:text-5xl">
            {t('auth.welcomeBack')}
          </h1>
          <p className="max-w-md text-[15px] text-muted-light dark:text-muted-dark">
            {t('auth.subTitle')}
          </p>

          <div className="mt-2 flex max-w-xl flex-col gap-3">
            <LoginHighlightRow
              icon={<Building2 size={20} />}
              title={t('auth.loginHighlightFacilitiesTitle')}
              description={t('auth.loginHighlightFacilitiesDesc')}
            />
            <LoginHighlightRow
              icon={<LineChart size={20} />}
              title={t('auth.loginHighlightIncomeTitle')}
              description={t('auth.loginHighlightIncomeDesc')}
            />
            <LoginHighlightRow
              icon={<CalendarClock size={20} />}
              title={t('auth.loginHighlightScheduleTitle')}
              description={t('auth.loginHighlightScheduleDesc')}
            />
          </div>
        </section>

        <section className="relative">
          <div
            className={cn(
              'relative mx-auto w-full max-w-md rounded-2xl p-6 md:p-8',
              'bg-surface-light/90 dark:bg-surface-dark/90 backdrop-blur-xl',
              'border border-black/5 dark:border-white/10 shadow-card-hover animate-scale-in',
            )}
          >
            <div className="mb-6 flex items-start justify-between gap-4">
              <div>
                <h2 className="text-xl font-extrabold md:text-2xl">
                  {t('auth.signIn')}
                </h2>
                <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
                  {t('auth.subTitle')}
                </p>
              </div>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <Input
                label={t('auth.usernameOrEmail')}
                type="text"
                leftIcon={<Mail size={16} />}
                value={email}
                onChange={(e) => setEmail(e.currentTarget.value)}
                autoComplete="username"
                required
              />
              <Input
                label={t('auth.password')}
                type={showPwd ? 'text' : 'password'}
                leftIcon={<Lock size={16} />}
                value={password}
                onChange={(e) => setPassword(e.currentTarget.value)}
                autoComplete="current-password"
                required
                rightAdornment={
                  <button
                    type="button"
                    onClick={() => setShowPwd((s) => !s)}
                    aria-label={
                      showPwd ? t('auth.hidePassword') : t('auth.showPassword')
                    }
                    className="inline-flex h-7 w-7 items-center justify-center rounded-md hover:bg-black/5 dark:hover:bg-white/10"
                  >
                    {showPwd ? <EyeOff size={14} /> : <Eye size={14} />}
                  </button>
                }
              />
              {loginError && (
                <p className="text-sm text-red-500 dark:text-red-400">{loginError}</p>
              )}
              <div className="flex items-center justify-between text-sm">
                <label className="inline-flex items-center gap-2 text-muted-light dark:text-muted-dark">
                  <input
                    type="checkbox"
                    defaultChecked
                    className="h-4 w-4 accent-brand-500"
                  />
                  {t('auth.rememberMe')}
                </label>
                <button
                  type="button"
                  className="text-brand-600 dark:text-brand-300 font-semibold hover:underline"
                >
                  {t('auth.forgot')}
                </button>
              </div>

              <Button type="submit" fullWidth size="lg" loading={loading}>
                {loading ? t('auth.signingIn') : t('auth.signIn')}
              </Button>

              <div className="rounded-lg border border-dashed border-brand-500/30 bg-brand-500/5 px-3 py-2 text-xs text-brand-700 dark:text-brand-300 space-y-0.5">
                <div>
                  <span className="font-semibold">{t('auth.demoLogin')}:</span> Danial
                </div>
              </div>
            </form>

            <div className="my-6 flex items-center gap-3 text-xs text-muted-light dark:text-muted-dark">
              <div className="h-px flex-1 bg-black/10 dark:bg-white/10" />
              <span>{t('auth.dontHaveFacility')}</span>
              <div className="h-px flex-1 bg-black/10 dark:bg-white/10" />
            </div>

            <Button
              variant="outline"
              fullWidth
              size="lg"
              onClick={() => setListFacilityOpen(true)}
              leftIcon={<Building2 size={18} />}
            >
              {t('auth.listFacility')}
            </Button>
          </div>
        </section>
      </main>

      <ListFacilityModal
        open={listFacilityOpen}
        onClose={() => setListFacilityOpen(false)}
      />
    </div>
  );
}

function LoginHighlightRow({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <div className="flex gap-4 rounded-xl border border-black/5 bg-surface-light/80 p-4 shadow-card backdrop-blur-sm dark:border-white/10 dark:bg-surface-dark/80">
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-brand-500/15 text-brand-700 dark:text-brand-300">
        {icon}
      </div>
      <div className="min-w-0">
        <h3 className="text-base font-extrabold text-text-light dark:text-text-dark">
          {title}
        </h3>
        <p className="mt-1 text-sm leading-relaxed text-muted-light dark:text-muted-dark">
          {description}
        </p>
      </div>
    </div>
  );
}

function BackgroundBlobs() {
  return (
    <div aria-hidden className="pointer-events-none absolute inset-0 overflow-hidden">
      <div className="absolute -top-40 -left-24 h-[420px] w-[420px] rounded-full bg-brand-500/25 blur-3xl dark:bg-brand-500/15" />
      <div className="absolute -bottom-40 -right-24 h-[520px] w-[520px] rounded-full bg-accent/25 blur-3xl dark:bg-accent/15" />
      <div className="absolute top-1/3 right-1/4 h-[320px] w-[320px] rounded-full bg-brand-800/20 blur-3xl dark:bg-brand-900/40" />
    </div>
  );
}

function ListFacilityModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const { t } = useTranslation();

  const steps = [
    t('auth.listFacilityStep1'),
    t('auth.listFacilityStep2'),
    t('auth.listFacilityStep3'),
  ];

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('auth.listFacilityTitle')}
      description={t('auth.listFacilitySubtitle')}
      size="md"
      footer={<Button onClick={onClose}>{t('common.close')}</Button>}
    >
      <div className="flex flex-col gap-5 py-2">
        <div className="flex items-center justify-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-brand-500/15 text-brand-700 dark:text-brand-300">
            <Smartphone size={32} />
          </div>
        </div>

        <ol className="space-y-3">
          {steps.map((step, index) => (
            <li key={index} className="flex gap-3 text-sm leading-relaxed">
              <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-brand-500/15 text-xs font-bold text-brand-700 dark:text-brand-300">
                {index + 1}
              </span>
              <span className="pt-0.5 text-text-light dark:text-text-dark">{step}</span>
            </li>
          ))}
        </ol>

        {(APP_STORE_URL || PLAY_STORE_URL) && (
          <div className="flex flex-col gap-2 sm:flex-row">
            {APP_STORE_URL && (
              <a
                href={APP_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex flex-1 items-center justify-center gap-2 rounded-xl border border-black/10 bg-black px-4 py-3 text-sm font-semibold text-white transition hover:bg-black/90 dark:border-white/10"
              >
                <Download size={16} />
                {t('auth.downloadAppStore')}
              </a>
            )}
            {PLAY_STORE_URL && (
              <a
                href={PLAY_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex flex-1 items-center justify-center gap-2 rounded-xl border border-black/10 bg-black px-4 py-3 text-sm font-semibold text-white transition hover:bg-black/90 dark:border-white/10"
              >
                <Download size={16} />
                {t('auth.downloadGooglePlay')}
              </a>
            )}
          </div>
        )}
      </div>
    </Modal>
  );
}
