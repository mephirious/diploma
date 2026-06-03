import type { ReactNode } from 'react';
import { cn } from '@/lib/cn';

export function DataTable({
  columns,
  rows,
  getKey,
  empty,
  onRowClick,
}: {
  columns: Array<{ key: string; header: ReactNode; cell: (row: any) => ReactNode; className?: string }>;
  rows: any[];
  getKey: (row: any) => string;
  empty: ReactNode;
  onRowClick?: (row: any) => void;
}) {
  if (rows.length === 0) {
    return (
      <div className="rounded-lg border border-dashed border-black/10 p-8 text-center text-sm text-muted-light dark:border-white/10 dark:text-muted-dark">
        {empty}
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-black/5 text-sm dark:divide-white/10">
        <thead>
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                className={cn(
                  'px-4 py-3 text-left text-xs font-bold uppercase tracking-wider text-muted-light dark:text-muted-dark',
                  column.className,
                )}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-black/5 dark:divide-white/10">
          {rows.map((row) => (
            <tr
              key={getKey(row)}
              onClick={() => onRowClick?.(row)}
              className={cn(
                'hover:bg-black/[0.025] dark:hover:bg-white/[0.04]',
                onRowClick && 'cursor-pointer',
              )}
            >
              {columns.map((column) => (
                <td key={column.key} className={cn('px-4 py-3 align-middle', column.className)}>
                  {column.cell(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
