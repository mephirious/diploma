import { type ReactNode } from 'react';
import { cn } from '@/lib/cn';

export function EmptyState({
  icon,
  title,
  description,
  action,
  className,
}: {
  icon?: ReactNode;
  title: ReactNode;
  description?: ReactNode;
  action?: ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center text-center rounded-xl border border-dashed',
        'border-black/10 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03]',
        'py-12 px-6',
        className,
      )}
    >
      {icon ? (
        <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-brand-500/10 text-brand-600 dark:text-brand-300">
          {icon}
        </div>
      ) : null}
      <h3 className="text-base font-bold text-text-light dark:text-text-dark">
        {title}
      </h3>
      {description ? (
        <p className="mt-1 max-w-sm text-sm text-muted-light dark:text-muted-dark">
          {description}
        </p>
      ) : null}
      {action ? <div className="mt-4">{action}</div> : null}
    </div>
  );
}
