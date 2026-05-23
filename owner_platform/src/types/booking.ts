/** Booking row from GET /booking/v1/bookings (`bookingBookingMain`). */
export type ApiBooking = {
  id: string;
  venue_id: string;
  resource_id: string;
  session_id?: string | null;
  user_id: string;
  status: string;
  payment_status: string;
  price_total: string | number;
  currency?: string | null;
  start_at?: string | null;
  end_at?: string | null;
  timezone?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
  hold_expires_at?: string | null;
  payment_intent_id?: string | null;
  cancel_reason?: string | null;
  cancelled_at?: string | null;
  confirmed_at?: string | null;
  completed_at?: string | null;
};
