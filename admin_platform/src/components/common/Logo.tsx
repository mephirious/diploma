import { ShieldCheck } from 'lucide-react';
import { cn } from '@/lib/cn';

export function Logo({ compact = false, className }: { compact?: boolean; className?: string }) {
  return (
    <div className={cn('flex items-center gap-2.5', className)}>
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-admin-500 shadow-admin">
        <ShieldCheck size={19} className="text-white" />
      </div>
      {!compact ? (
        <div className="min-w-0">
          <div className="text-[15px] font-extrabold leading-none text-text-light dark:text-text-dark">
            ZhamSpace
          </div>
          <div className="mt-1 text-[10px] font-semibold uppercase tracking-widest text-admin-600 dark:text-admin-300">
            Admin Platform
          </div>
        </div>
      ) : null}
    </div>
  );
}
