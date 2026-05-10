/** Lightweight booking shape surfaced in the owner dashboard. */
export type OwnerBooking = {
  id: string;
  facility_id: string;
  facility_name: string;
  resource_name: string;
  customer_name: string;
  /** ISO8601. */
  start_at: string;
  end_at: string;
  attendees: number;
  price: number;
  currency: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
};
