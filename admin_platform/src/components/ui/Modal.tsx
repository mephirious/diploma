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
  /** Max height of the dialog panel (viewport-relative). Body scrolls inside. Default 85vh. */
  maxHeight?: string;
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
  maxHeight = '85vh',
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
      className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto p-4 pt-[max(1rem,env(safe-area-inset-top))] pb-[max(1rem,env(safe-area-inset-bottom))] sm:items-center sm:py-8 animate-fade-in"
      role="dialog"
      aria-modal="true"
    >
      <div
        className="fixed inset-0 z-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        className={cn(
          'relative z-10 flex w-full min-h-0 flex-col overflow-hidden rounded-xl',
          'bg-surface-light dark:bg-surface-dark shadow-card-hover',
          'border border-black/5 dark:border-white/10 animate-scale-in',
          sizeClasses[size],
        )}
        style={{ maxHeight }}
      >
        <div className="flex shrink-0 items-start justify-between gap-3 border-b border-black/5 px-5 pb-3 pt-5 dark:border-white/10">
          <div className="min-w-0">
            {title ? (
              <h2 className="text-lg font-bold text-text-light dark:text-text-dark">
                {title}
              </h2>
            ) : null}
            {description ? (
              <p className="mt-1 break-all text-sm text-muted-light dark:text-muted-dark">
                {description}
              </p>
            ) : null}
          </div>
          <button
            onClick={onClose}
            type="button"
            aria-label="Close"
            className="ml-2 inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-lg text-muted-light hover:bg-black/5 dark:text-muted-dark dark:hover:bg-white/10 focus-ring"
          >
            <X size={18} />
          </button>
        </div>

        <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-5 py-4">{children}</div>

        {footer ? (
          <div className="flex shrink-0 items-center justify-end gap-2 border-t border-black/5 px-4 py-3 dark:border-white/10">
            {footer}
          </div>
        ) : null}
      </div>
    </div>,
    document.body,
  );
}
