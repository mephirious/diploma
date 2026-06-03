import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Button } from '@/components/ui/Button';

export function NotFoundPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen items-center justify-center bg-bg-light dark:bg-bg-dark px-6 text-center">
      <div>
        <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-admin-500/15 text-admin-700 dark:text-admin-300 text-3xl font-extrabold">
          404
        </div>
        <h1 className="mb-2 text-3xl font-extrabold">Page not found</h1>
        <p className="mb-6 text-muted-light dark:text-muted-dark">
          The page you are looking for has been moved or doesn&apos;t exist.
        </p>
        <Link to="/dashboard">
          <Button>{t('common.back')}</Button>
        </Link>
      </div>
    </div>
  );
}
