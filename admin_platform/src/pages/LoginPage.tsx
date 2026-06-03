import { useState, type FormEvent } from 'react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { Eye, EyeOff, Lock, ShieldCheck, UserRound } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { LanguageMenu } from '@/components/common/LanguageMenu';
import { Logo } from '@/components/common/Logo';
import { ThemeToggle } from '@/components/common/ThemeToggle';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { useAdminAuth } from '@/store/auth';

export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const isAuthenticated = useAdminAuth((s) => s.isAuthenticated);
  const login = useAdminAuth((s) => s.login);

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (isAuthenticated) {
    const from =
      (location.state as { from?: { pathname?: string } } | null)?.from?.pathname ?? '/dashboard';
    return <Navigate to={from} replace />;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await login({ username: username.trim(), password });
      navigate('/dashboard', { replace: true });
    } catch {
      setError(t('auth.invalidCredentials'));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-bg-light text-text-light dark:bg-bg-dark dark:text-text-dark">
      <header className="flex items-center justify-between px-6 py-5 md:px-10">
        <Logo />
        <div className="flex items-center gap-1">
          <LanguageMenu />
          <ThemeToggle />
        </div>
      </header>

      <main className="mx-auto grid min-h-[calc(100vh-88px)] max-w-6xl items-center gap-10 px-6 py-8 md:grid-cols-[1fr_420px] md:px-10">
        <section className="hidden md:block">
          <div className="inline-flex items-center gap-2 rounded-full bg-admin-500/12 px-3 py-1.5 text-xs font-bold uppercase tracking-widest text-admin-700 dark:text-admin-300">
            <ShieldCheck size={14} />
            {t('app.tagline')}
          </div>
          <h1 className="mt-5 max-w-xl text-4xl font-extrabold leading-tight md:text-5xl">
            {t('dashboard.title')}
          </h1>
          <p className="mt-4 max-w-lg text-[15px] text-muted-light dark:text-muted-dark">
            {t('dashboard.subtitle')}
          </p>
        </section>

        <section className="rounded-xl border border-black/5 bg-surface-light p-6 shadow-card-hover dark:border-white/10 dark:bg-surface-dark md:p-8">
          <div className="mb-6">
            <h2 className="text-2xl font-extrabold">{t('auth.title')}</h2>
            <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
              {t('auth.subtitle')}
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label={t('auth.username')}
              value={username}
              onChange={(e) => setUsername(e.currentTarget.value)}
              leftIcon={<UserRound size={16} />}
              autoComplete="username"
              required
            />
            <Input
              label={t('auth.password')}
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.currentTarget.value)}
              leftIcon={<Lock size={16} />}
              autoComplete="current-password"
              required
              rightAdornment={
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="inline-flex h-7 w-7 items-center justify-center rounded-md hover:bg-black/5 dark:hover:bg-white/10"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                </button>
              }
            />
            {error ? <p className="text-sm text-danger">{error}</p> : null}
            <Button
              type="submit"
              fullWidth
              size="lg"
              loading={loading}
              className="bg-admin-500 shadow-admin hover:bg-admin-600"
            >
              {loading ? t('auth.signingIn') : t('auth.signIn')}
            </Button>

            <div className="space-y-0.5 rounded-lg border border-dashed border-admin-500/30 bg-admin-500/5 px-3 py-2 text-xs text-admin-700 dark:text-admin-300">
              <div>
                <span className="font-semibold">{t('auth.demoLogin')}:</span> Admin
              </div>
              <div>
                <span className="font-semibold">{t('auth.demoPassword')}:</span> 2006DaniaL
              </div>
            </div>
          </form>
        </section>
      </main>
    </div>
  );
}
