import type { ReactNode } from 'react';
import { Card, CardBody } from './Card';
import { cn } from '@/lib/cn';

export function StatCard({
  title,
  value,
  detail,
  icon,
  tone = 'admin',
}: {
  title: ReactNode;
  value: ReactNode;
  detail?: ReactNode;
  icon?: ReactNode;
  tone?: 'admin' | 'success' | 'warning' | 'info';
}) {
  const toneClass = {
    admin: 'bg-admin-500/12 text-admin-700 dark:text-admin-300',
    success: 'bg-success/12 text-success',
    warning: 'bg-warning/12 text-warning',
    info: 'bg-info/12 text-info',
  }[tone];

  return (
    <Card>
      <CardBody className="flex items-start justify-between gap-4">
        <div className="min-w-0">
          <div className="text-sm font-semibold text-muted-light dark:text-muted-dark">
            {title}
          </div>
          <div className="mt-2 truncate text-2xl font-extrabold text-text-light dark:text-text-dark">
            {value}
          </div>
          {detail ? (
            <div className="mt-1 text-xs text-muted-light dark:text-muted-dark">{detail}</div>
          ) : null}
        </div>
        {icon ? (
          <div className={cn('flex h-11 w-11 shrink-0 items-center justify-center rounded-lg', toneClass)}>
            {icon}
          </div>
        ) : null}
      </CardBody>
    </Card>
  );
}
