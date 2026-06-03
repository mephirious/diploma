import { type ReactNode } from 'react';
import { cn } from '@/lib/cn';

export function PageHeader({
  title,
  subtitle,
  actions,
  eyebrow,
  className,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  actions?: ReactNode;
  eyebrow?: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('flex flex-wrap items-start justify-between gap-4 mb-6', className)}>
      <div className="min-w-0">
        {eyebrow ? (
          <div className="mb-1 text-[12px] font-bold uppercase tracking-widest text-brand-600 dark:text-brand-300">
            {eyebrow}
          </div>
        ) : null}
        <h1 className="text-2xl font-extrabold leading-tight text-text-light dark:text-text-dark md:text-3xl">
          {title}
        </h1>
        {subtitle ? (
          <p className="mt-1 max-w-2xl text-sm text-muted-light dark:text-muted-dark md:text-[15px]">
            {subtitle}
          </p>
        ) : null}
      </div>
      {actions ? <div className="flex shrink-0 flex-wrap items-center gap-2">{actions}</div> : null}
    </div>
  );
}
