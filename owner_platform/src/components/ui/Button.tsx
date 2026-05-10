import { forwardRef, type ButtonHTMLAttributes, type ReactNode } from 'react';
import { cn } from '@/lib/cn';

type Variant = 'primary' | 'secondary' | 'ghost' | 'outline' | 'danger';
type Size = 'sm' | 'md' | 'lg';

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  size?: Size;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  loading?: boolean;
  fullWidth?: boolean;
};

const variants: Record<Variant, string> = {
  primary:
    'bg-brand-500 hover:bg-brand-600 text-white shadow-brand hover:shadow-brand disabled:bg-brand-500/60 disabled:shadow-none',
  secondary:
    'bg-brand-800 hover:bg-brand-900 text-white disabled:bg-brand-800/60',
  ghost:
    'bg-transparent hover:bg-black/5 dark:hover:bg-white/10 text-text-light dark:text-text-dark',
  outline:
    'bg-transparent border border-black/10 dark:border-white/15 text-text-light dark:text-text-dark hover:bg-black/5 dark:hover:bg-white/10',
  danger:
    'bg-danger hover:bg-red-600 text-white disabled:bg-danger/60',
};

const sizes: Record<Size, string> = {
  sm: 'h-9 px-3 text-sm rounded-md gap-1.5',
  md: 'h-11 px-5 text-[15px] rounded-lg gap-2',
  lg: 'h-12 px-6 text-base rounded-lg gap-2',
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  {
    variant = 'primary',
    size = 'md',
    leftIcon,
    rightIcon,
    loading = false,
    fullWidth = false,
    className,
    children,
    disabled,
    type = 'button',
    ...rest
  },
  ref,
) {
  return (
    <button
      ref={ref}
      type={type}
      disabled={disabled || loading}
      className={cn(
        'relative inline-flex items-center justify-center font-semibold',
        'transition-all duration-150 select-none focus-ring',
        'disabled:cursor-not-allowed',
        variants[variant],
        sizes[size],
        fullWidth && 'w-full',
        className,
      )}
      {...rest}
    >
      {loading ? (
        <span className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
      ) : (
        <>
          {leftIcon ? <span className="inline-flex shrink-0">{leftIcon}</span> : null}
          <span className="inline-flex">{children}</span>
          {rightIcon ? <span className="inline-flex shrink-0">{rightIcon}</span> : null}
        </>
      )}
    </button>
  );
});
