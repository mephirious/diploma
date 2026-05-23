import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from 'recharts';
import { useTheme } from '@/store/theme';
import { formatPrice } from '@/lib/format';

export type RevenueChartPoint = {
  label: string;
  revenue: number;
  bookings: number;
};

export function RevenueChart({ data }: { data: RevenueChartPoint[] }) {
  useTheme((s) => s.mode);
  const isDark = document.documentElement.classList.contains('dark');

  const axisColor = isDark ? '#94A3B8' : '#6B7280';
  const gridColor = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)';

  if (!data.length) {
    return (
      <div className="flex h-64 items-center justify-center text-sm font-semibold text-muted-light dark:text-muted-dark">
        —
      </div>
    );
  }

  return (
    <div className="h-64 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={data} margin={{ left: 0, right: 8, top: 8, bottom: 0 }}>
          <defs>
            <linearGradient id="revenueFill" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#00BFA5" stopOpacity={0.42} />
              <stop offset="100%" stopColor="#00BFA5" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="4 4" stroke={gridColor} vertical={false} />
          <XAxis
            dataKey="label"
            stroke={axisColor}
            tickLine={false}
            axisLine={false}
            fontSize={12}
          />
          <YAxis
            stroke={axisColor}
            tickLine={false}
            axisLine={false}
            fontSize={12}
            tickFormatter={(v: number) => `${(v / 1000).toFixed(0)}k`}
            width={44}
          />
          <Tooltip
            cursor={{ stroke: '#00BFA5', strokeOpacity: 0.2, strokeWidth: 24 }}
            contentStyle={{
              background: isDark ? '#1A2737' : '#FFFFFF',
              borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.06)',
              borderRadius: 12,
              fontSize: 12,
              padding: '8px 12px',
              color: isDark ? '#F1F5F9' : '#1A1A2E',
            }}
            labelStyle={{ color: isDark ? '#94A3B8' : '#6B7280', fontWeight: 600 }}
            formatter={(val: number, name) => {
              if (name === 'revenue') return [formatPrice(val), 'Revenue'];
              if (name === 'bookings') return [val, 'Payments'];
              return [val, name as string];
            }}
          />
          <Area
            type="monotone"
            dataKey="revenue"
            stroke="#00BFA5"
            strokeWidth={2.5}
            fill="url(#revenueFill)"
            activeDot={{ r: 5, strokeWidth: 0 }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
