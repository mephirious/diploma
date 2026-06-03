/** Mirrors the mobile `ResourceModel` (backend `venueResourceMain`). */
export type Resource = {
  id: string;
  venue_id: string;
  name: string | null;
  description: string | null;
  /** e.g. "court", "field", "lane", "table". Free-form on backend. */
  type: string | null;
  sport: string | null;
  capacity: number | null;
  status: 'active' | 'inactive' | 'maintenance' | null;
  surface: string | null;
  images: string[];
  created_at?: string;
  updated_at?: string;
};
