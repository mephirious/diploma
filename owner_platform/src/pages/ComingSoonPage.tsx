import { useTranslation } from 'react-i18next';
import { Sparkles } from 'lucide-react';
import { EmptyState } from '@/components/ui/EmptyState';
import { PageHeader } from '@/components/common/PageHeader';

export function ComingSoonPage({ titleKey }: { titleKey: string }) {
  const { t } = useTranslation();
  return (
    <div>
      <PageHeader title={t(titleKey)} subtitle={t('common.comingSoon')} />
      <EmptyState
        icon={<Sparkles size={22} />}
        title={t('common.comingSoon')}
        description={t('common.noResults')}
      />
    </div>
  );
}
