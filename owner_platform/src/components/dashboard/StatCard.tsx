import { ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { type ReactNode } from 'react';
import { Card, CardBody } from '@/components/ui/Card';
import { cn } from '@/lib/cn';

export function StatCard({
  icon,
  label,
  value,
  delta,
  accent = 'brand',
}: {
  icon: ReactNode;
  label: string;
  value: string;
  delta?: number;
  accent?: 'brand' | 'info' | 'success' | 'warning';
}) {
  const accentClasses: Record<NonNullable<typeof accent>, string> = {
    brand: 'bg-brand-500/12 text-brand-700 dark:text-brand-300',
    info: 'bg-info/12 text-info',
    success: 'bg-success/12 text-success',
    warning: 'bg-warning/20 text-[#b4700a] dark:text-warning',
  };

  const hasDelta = typeof delta === 'number' && Number.isFinite(delta);
  const positive = hasDelta ? delta! >= 0 : false;

  return (
    <Card>
      <CardBody>
        <div className="flex items-start justify-between">
          <div
            className={cn(
              'flex h-11 w-11 items-center justify-center rounded-lg',
              accentClasses[accent],
            )}
          >
            {icon}
          </div>
          {hasDelta ? (
            <div
              className={cn(
                'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-bold',
                positive
                  ? 'bg-success/15 text-success'
                  : 'bg-danger/15 text-danger',
              )}
            >
              {positive ? (
                <ArrowUpRight size={12} />
              ) : (
                <ArrowDownRight size={12} />
              )}
              {Math.abs(delta! * 100).toFixed(0)}%
            </div>
          ) : null}
        </div>
        <div className="mt-4">
          <div className="text-3xl font-extrabold text-text-light dark:text-text-dark">
            {value}
          </div>
          <div className="mt-1 text-sm text-muted-light dark:text-muted-dark">
            {label}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
