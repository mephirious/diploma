import {
  forwardRef,
  useId,
  type InputHTMLAttributes,
  type ReactNode,
  type TextareaHTMLAttributes,
  type SelectHTMLAttributes,
} from 'react';
import { cn } from '@/lib/cn';

type BaseFieldProps = {
  label?: ReactNode;
  hint?: ReactNode;
  error?: ReactNode;
  leftIcon?: ReactNode;
  rightAdornment?: ReactNode;
};

const fieldShell =
  'flex items-center w-full rounded-lg bg-black/[0.04] dark:bg-white/[0.06] px-3 h-11 text-[15px] text-text-light dark:text-text-dark placeholder:text-muted-light dark:placeholder:text-muted-dark border border-transparent focus-within:border-brand-500 focus-within:bg-surface-light dark:focus-within:bg-surface-dark transition-colors';

function FieldLabel({ id, children }: { id: string; children: ReactNode }) {
  return (
    <label
      htmlFor={id}
      className="block text-[13px] font-semibold text-text-light dark:text-text-dark mb-1.5"
    >
      {children}
    </label>
  );
}

function FieldHint({ hint, error }: { hint?: ReactNode; error?: ReactNode }) {
  if (!hint && !error) return null;
  return (
    <p
      className={cn(
        'mt-1.5 text-xs',
        error ? 'text-danger' : 'text-muted-light dark:text-muted-dark',
      )}
    >
      {error ?? hint}
    </p>
  );
}

export type InputProps = InputHTMLAttributes<HTMLInputElement> & BaseFieldProps;

export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  {
    label,
    hint,
    error,
    leftIcon,
    rightAdornment,
    className,
    id: idProp,
    ...rest
  },
  ref,
) {
  const reactId = useId();
  const id = idProp ?? reactId;

  return (
    <div className={cn('w-full', className)}>
      {label ? <FieldLabel id={id}>{label}</FieldLabel> : null}
      <div className={cn(fieldShell, error && 'border-danger/60')}>
        {leftIcon ? (
          <span className="mr-2 text-muted-light dark:text-muted-dark">
            {leftIcon}
          </span>
        ) : null}
        <input
          ref={ref}
          id={id}
          className="flex-1 bg-transparent outline-none placeholder:text-muted-light dark:placeholder:text-muted-dark"
          {...rest}
        />
        {rightAdornment ? (
          <span className="ml-2 shrink-0 text-muted-light dark:text-muted-dark">
            {rightAdornment}
          </span>
        ) : null}
      </div>
      <FieldHint hint={hint} error={error} />
    </div>
  );
});

export type TextareaProps = TextareaHTMLAttributes<HTMLTextAreaElement> &
  BaseFieldProps;

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  function Textarea(
    { label, hint, error, className, id: idProp, rows = 4, ...rest },
    ref,
  ) {
    const reactId = useId();
    const id = idProp ?? reactId;
    return (
      <div className={cn('w-full', className)}>
        {label ? <FieldLabel id={id}>{label}</FieldLabel> : null}
        <textarea
          ref={ref}
          id={id}
          rows={rows}
          className={cn(
            'block w-full rounded-lg bg-black/[0.04] dark:bg-white/[0.06] px-3 py-2.5 text-[15px]',
            'text-text-light dark:text-text-dark placeholder:text-muted-light dark:placeholder:text-muted-dark',
            'border border-transparent focus:border-brand-500 focus:bg-surface-light dark:focus:bg-surface-dark outline-none transition-colors resize-y',
            error && 'border-danger/60',
          )}
          {...rest}
        />
        <FieldHint hint={hint} error={error} />
      </div>
    );
  },
);

export type SelectProps = SelectHTMLAttributes<HTMLSelectElement> &
  BaseFieldProps & { options: Array<{ value: string; label: string }> };

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  function Select(
    { label, hint, error, options, className, id: idProp, ...rest },
    ref,
  ) {
    const reactId = useId();
    const id = idProp ?? reactId;
    return (
      <div className={cn('w-full', className)}>
        {label ? <FieldLabel id={id}>{label}</FieldLabel> : null}
        <div className={cn(fieldShell, 'pr-2', error && 'border-danger/60')}>
          <select
            ref={ref}
            id={id}
            className="flex-1 bg-transparent outline-none appearance-none pr-1"
            {...rest}
          >
            {options.map((o) => (
              <option
                key={o.value}
                value={o.value}
                className="bg-surface-light text-text-light dark:bg-surface-dark dark:text-text-dark"
              >
                {o.label}
              </option>
            ))}
          </select>
          <span className="pointer-events-none text-muted-light dark:text-muted-dark">
            ▾
          </span>
        </div>
        <FieldHint hint={hint} error={error} />
      </div>
    );
  },
);
