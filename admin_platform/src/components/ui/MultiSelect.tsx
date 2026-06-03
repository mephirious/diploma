import { useId, type ReactNode } from 'react';
import { cn } from '@/lib/cn';

export type MultiSelectOption = { value: string; label: string };

type MultiSelectProps = {
  label?: ReactNode;
  hint?: ReactNode;
  error?: ReactNode;
  options: MultiSelectOption[];
  value: string[];
  onChange: (value: string[]) => void;
  className?: string;
};

export function MultiSelect({
  label,
  hint,
  error,
  options,
  value,
  onChange,
  className,
}: MultiSelectProps) {
  const id = useId();

  const toggle = (optionValue: string) => {
    if (value.includes(optionValue)) {
      onChange(value.filter((v) => v !== optionValue));
    } else {
      onChange([...value, optionValue]);
    }
  };

  return (
    <div className={cn('w-full', className)}>
      {label ? (
        <span
          id={`${id}-label`}
          className="block text-[13px] font-semibold text-text-light dark:text-text-dark mb-1.5"
        >
          {label}
        </span>
      ) : null}
      <div
        role="group"
        aria-labelledby={label ? `${id}-label` : undefined}
        className={cn(
          'max-h-48 overflow-y-auto rounded-lg border border-black/5 dark:border-white/10',
          'bg-black/[0.02] dark:bg-white/[0.03] p-2 grid gap-1 sm:grid-cols-2',
          error && 'border-danger/60',
        )}
      >
        {options.map((o) => {
          const checked = value.includes(o.value);
          return (
            <label
              key={o.value}
              className={cn(
                'flex cursor-pointer items-center gap-2 rounded-md px-2.5 py-2 text-sm transition-colors',
                checked
                  ? 'bg-brand-500/12 font-semibold text-brand-800 dark:text-brand-200'
                  : 'hover:bg-black/[0.04] dark:hover:bg-white/[0.06]',
              )}
            >
              <input
                type="checkbox"
                className="h-4 w-4 rounded border-black/20 text-brand-600 focus:ring-brand-500"
                checked={checked}
                onChange={() => toggle(o.value)}
              />
              <span>{o.label}</span>
            </label>
          );
        })}
      </div>
      {hint || error ? (
        <p
          className={cn(
            'mt-1.5 text-xs',
            error ? 'text-danger' : 'text-muted-light dark:text-muted-dark',
          )}
        >
          {error ?? hint}
        </p>
      ) : null}
    </div>
  );
}
