export interface Promo {
  id: string;
  venue_id: string;
  resource_id: string | null;
  owner_id: string;
  created_at: string;
  updated_at: string;

  name: string;
  description: string | null;
  code: string | null;

  /** 'percentage' | 'fixed_amount' */
  type: PromoType;

  /** 1-100, set when type = 'percentage' */
  discount_percent: number | null;
  /** minor currency units, set when type = 'fixed_amount' */
  discount_minor: number | null;

  min_duration_minutes: number | null;
  min_booking_price_minor: number | null;

  valid_from: string;
  valid_to: string | null;

  max_uses: number | null;
  uses_count: number;
  max_uses_per_user: number | null;

  /** 0=Sun…6=Sat; empty = any day */
  applicable_days: number[];

  currency: string;
  status: PromoStatus;
}

export type PromoType = 'percentage' | 'fixed_amount';
export type PromoStatus = 'active' | 'inactive';

export interface PromoCreatePayload {
  resource_id?: string;
  name: string;
  description?: string;
  code?: string;
  type: PromoType;
  discount_percent?: number;
  discount_minor?: number;
  min_duration_minutes?: number;
  min_booking_price_minor?: number;
  valid_from: string;
  valid_to?: string;
  max_uses?: number;
  max_uses_per_user?: number;
  applicable_days?: number[];
  currency?: string;
  status?: PromoStatus;
}

export interface PromoUpdatePayload {
  name?: string;
  description?: string;
  code?: string;
  type?: PromoType;
  discount_percent?: number;
  discount_minor?: number;
  min_duration_minutes?: number;
  min_booking_price_minor?: number;
  valid_from?: string;
  valid_to?: string;
  max_uses?: number;
  max_uses_per_user?: number;
  applicable_days?: number[];
  currency?: string;
  status?: PromoStatus;
}

export interface PromoListResponse {
  pagination_info: {
    page: number;
    page_size: number;
    total_count: number;
  };
  results: Promo[];
}
