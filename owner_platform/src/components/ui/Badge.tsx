import { type HTMLAttributes } from 'react';
import { cn } from '@/lib/cn';

type Tone =
  | 'brand'
  | 'success'
  | 'warning'
  | 'danger'
  | 'info'
  | 'neutral'
  | 'muted';

export type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  tone?: Tone;
  outline?: boolean;
};

const toneStyles: Record<Tone, string> = {
  brand: 'bg-brand-500/15 text-brand-700 dark:text-brand-300',
  success: 'bg-success/15 text-success',
  warning: 'bg-warning/15 text-[#b4700a] dark:text-warning',
  danger: 'bg-danger/15 text-danger',
  info: 'bg-info/15 text-info',
  neutral:
    'bg-black/10 text-text-light dark:bg-white/10 dark:text-text-dark',
  muted:
    'bg-black/5 text-muted-light dark:bg-white/10 dark:text-muted-dark',
};

const outlineStyles: Record<Tone, string> = {
  brand: 'border-brand-500/40 text-brand-700 dark:text-brand-300',
  success: 'border-success/40 text-success',
  warning: 'border-warning/40 text-[#b4700a] dark:text-warning',
  danger: 'border-danger/40 text-danger',
  info: 'border-info/40 text-info',
  neutral: 'border-black/15 text-text-light dark:border-white/20 dark:text-text-dark',
  muted: 'border-black/10 text-muted-light dark:border-white/15 dark:text-muted-dark',
};

export function Badge({
  tone = 'brand',
  outline = false,
  className,
  ...props
}: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-[11px] font-semibold leading-none tracking-wide',
        outline ? `border ${outlineStyles[tone]}` : toneStyles[tone],
        className,
      )}
      {...props}
    />
  );
}
