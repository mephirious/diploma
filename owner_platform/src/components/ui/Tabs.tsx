import { type ReactNode } from 'react';
import { cn } from '@/lib/cn';

export type TabItem<T extends string> = {
  id: T;
  label: ReactNode;
  icon?: ReactNode;
};

export function Tabs<T extends string>({
  items,
  value,
  onChange,
  className,
}: {
  items: TabItem<T>[];
  value: T;
  onChange: (id: T) => void;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'inline-flex flex-wrap items-center gap-1 rounded-lg p-1',
        'bg-black/[0.04] dark:bg-white/[0.06]',
        className,
      )}
      role="tablist"
    >
      {items.map((item) => {
        const active = item.id === value;
        return (
          <button
            key={item.id}
            type="button"
            role="tab"
            aria-selected={active}
            onClick={() => onChange(item.id)}
            className={cn(
              'relative inline-flex items-center gap-2 rounded-md px-3.5 h-9 text-sm font-semibold transition-all',
              active
                ? 'bg-brand-500 text-white shadow-brand'
                : 'text-muted-light dark:text-muted-dark hover:text-text-light dark:hover:text-text-dark',
            )}
          >
            {item.icon}
            {item.label}
          </button>
        );
      })}
    </div>
  );
}
