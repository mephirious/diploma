import { useTranslation } from 'react-i18next';
import { PageHeader } from '@/components/common/PageHeader';

export function SupportPage() {
  const { t } = useTranslation();

  return (
    <div>
      <PageHeader title={t('nav.support')} />
    </div>
  );
}
