import { forwardRef, type ButtonHTMLAttributes, type ReactNode } from 'react';
import { cn } from '@/lib/cn';

type Size = 'sm' | 'md';

export type IconButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  icon: ReactNode;
  size?: Size;
  tone?: 'neutral' | 'brand' | 'danger';
  'aria-label': string;
};

const sizes: Record<Size, string> = {
  sm: 'h-8 w-8 rounded-md text-[13px]',
  md: 'h-10 w-10 rounded-lg text-[15px]',
};

export const IconButton = forwardRef<HTMLButtonElement, IconButtonProps>(
  function IconButton(
    { icon, size = 'md', tone = 'neutral', className, type = 'button', ...rest },
    ref,
  ) {
    return (
      <button
        ref={ref}
        type={type}
        className={cn(
          'inline-flex items-center justify-center transition-colors focus-ring',
          sizes[size],
          tone === 'neutral' &&
            'text-muted-light hover:text-text-light hover:bg-black/5 dark:text-muted-dark dark:hover:text-text-dark dark:hover:bg-white/10',
          tone === 'brand' &&
            'text-brand-600 hover:text-brand-700 hover:bg-brand-500/10 dark:text-brand-300 dark:hover:text-brand-200',
          tone === 'danger' &&
            'text-danger hover:bg-danger/10',
          className,
        )}
        {...rest}
      >
        {icon}
      </button>
    );
  },
);
