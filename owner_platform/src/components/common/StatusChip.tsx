import { useTranslation } from 'react-i18next';
import { Badge } from '@/components/ui/Badge';

type Status = 'active' | 'draft' | 'suspended' | 'inactive' | 'maintenance';

export function StatusChip({ status }: { status: Status }) {
  const { t } = useTranslation();
  switch (status) {
    case 'active':
      return <Badge tone="success">{t('facilities.activeBadge')}</Badge>;
    case 'draft':
      return <Badge tone="warning">{t('facilities.draftBadge')}</Badge>;
    case 'suspended':
      return <Badge tone="danger">{t('facilities.suspendedBadge')}</Badge>;
    case 'maintenance':
      return <Badge tone="info">{t('common.maintenance')}</Badge>;
    case 'inactive':
    default:
      return <Badge tone="muted">{t('common.inactive')}</Badge>;
  }
}
