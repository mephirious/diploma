import { useEffect, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { cn } from '@/lib/cn';

export type ModalProps = {
  open: boolean;
  onClose: () => void;
  title?: ReactNode;
  description?: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
};

const sizeClasses: Record<NonNullable<ModalProps['size']>, string> = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
};

export function Modal({
  open,
  onClose,
  title,
  description,
  children,
  footer,
  size = 'md',
}: ModalProps) {
  useEffect(() => {
    if (!open) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    window.addEventListener('keydown', onKey);
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = '';
    };
  }, [open, onClose]);

  if (!open) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 animate-fade-in"
      role="dialog"
      aria-modal="true"
    >
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        className={cn(
          'relative w-full rounded-xl bg-surface-light dark:bg-surface-dark shadow-card-hover',
          'border border-black/5 dark:border-white/10 animate-scale-in',
          sizeClasses[size],
        )}
      >
        <div className="flex items-start justify-between gap-3 p-5 pb-3">
          <div className="min-w-0">
            {title ? (
              <h2 className="text-lg font-bold text-text-light dark:text-text-dark">
                {title}
              </h2>
            ) : null}
            {description ? (
              <p className="mt-1 text-sm text-muted-light dark:text-muted-dark">
                {description}
              </p>
            ) : null}
          </div>
          <button
            onClick={onClose}
            type="button"
            aria-label="Close"
            className="ml-2 inline-flex h-9 w-9 items-center justify-center rounded-lg text-muted-light hover:bg-black/5 dark:text-muted-dark dark:hover:bg-white/10 focus-ring"
          >
            <X size={18} />
          </button>
        </div>

        <div className="px-5 pb-5">{children}</div>

        {footer ? (
          <div className="flex items-center justify-end gap-2 border-t border-black/5 dark:border-white/10 p-4">
            {footer}
          </div>
        ) : null}
      </div>
    </div>,
    document.body,
  );
}
