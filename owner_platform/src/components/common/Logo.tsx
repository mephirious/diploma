import { cn } from '@/lib/cn';

export function Logo({ compact = false, className }: { compact?: boolean; className?: string }) {
  return (
    <div className={cn('flex items-center gap-2.5', className)}>
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brand-gradient shadow-brand">
        <svg
          viewBox="0 0 24 24"
          width={18}
          height={18}
          fill="none"
          stroke="white"
          strokeWidth={2.4}
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M12 3l8 4v6c0 4.5-3.3 8-8 9-4.7-1-8-4.5-8-9V7l8-4z" />
          <path d="M9 12l2 2 4-4" />
        </svg>
      </div>
      {!compact ? (
        <div className="min-w-0">
          <div className="text-[15px] font-extrabold leading-none text-text-light dark:text-text-dark">
            ZhamSpace
          </div>
          <div className="mt-1 text-[10px] font-semibold uppercase tracking-widest text-brand-600 dark:text-brand-300">
            Owner Platform
          </div>
        </div>
      ) : null}
    </div>
  );
}
