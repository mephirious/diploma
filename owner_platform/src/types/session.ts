export type SessionMode = 'scheduled' | 'open' | 'on_demand';
export type SessionStatus = 'open' | 'locked' | 'active' | 'completed' | 'cancelled';
export type TemplateStatus = 'active' | 'paused' | 'archived';
export type SessionPricingModel = 'fixed_split' | 'per_person';
export type SessionVisibility = 'public' | 'link_only' | 'private';

export interface SessionTemplate {
  id: string;
  owner_id: string;
  venue_id: string;
  resource_id: string;
  name: string;
  description?: string | null;
  mode: SessionMode;
  sport: string;
  day_of_week?: number | null;
  start_time?: string | null;
  end_time?: string | null;
  timezone: string;
  effective_from?: string | null;
  effective_to?: string | null;
  min_participants: number;
  max_participants: number;
  pricing_model: SessionPricingModel;
  price_total_minor?: number | null;
  price_per_person_minor?: number | null;
  currency: string;
  lock_before_minutes: number;
  visibility: SessionVisibility;
  invite_code?: string | null;
  status: TemplateStatus;
  created_at: string;
  updated_at: string;
}

export interface SessionInstance {
  id: string;
  template_id?: string | null;
  owner_id?: string;
  venue_id: string;
  resource_id: string;
  name: string;
  description?: string | null;
  mode: SessionMode;
  sport: string;
  starts_at: string;
  ends_at: string;
  locks_at: string;
  timezone: string;
  min_participants: number;
  max_participants: number;
  participant_count: number;
  pricing_model: SessionPricingModel;
  price_total_minor?: number | null;
  price_per_person_minor?: number | null;
  locked_price_per_person_minor?: number | null;
  currency: string;
  visibility: SessionVisibility;
  invite_code?: string | null;
  status: SessionStatus;
  cancel_reason?: string | null;
  price_range?: { min_minor: number; max_minor: number } | null;
  created_at: string;
  updated_at: string;
}

export interface SessionParticipant {
  id: string;
  session_id: string;
  user_id: string;
  quoted_price_minor: number;
  final_price_minor?: number | null;
  currency: string;
  payment_status: string;
  status: string;
  joined_at: string;
  cancelled_at?: string | null;
}

export interface PaginatedTemplates {
  items: SessionTemplate[];
  total: number;
  page: number;
  page_size: number;
}

export interface PaginatedSessions {
  items: SessionInstance[];
  total: number;
  page: number;
  page_size: number;
}

export interface SessionParticipantsOwner {
  participant_count: number;
  max_participants: number;
  participants: SessionParticipant[];
}

export type TemplateCreatePayload = {
  resource_id: string;
  name: string;
  description?: string;
  mode: 'scheduled' | 'open';
  sport: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  timezone?: string;
  effective_from: string;
  effective_to?: string;
  min_participants: number;
  max_participants: number;
  pricing_model: SessionPricingModel;
  price_total_minor?: number;
  price_per_person_minor?: number;
  currency?: string;
  lock_before_minutes?: number;
  visibility?: SessionVisibility;
};

export type TemplateUpdatePayload = Partial<{
  name: string;
  description: string;
  effective_to: string;
  min_participants: number;
  max_participants: number;
  pricing_model: SessionPricingModel;
  price_total_minor: number;
  price_per_person_minor: number;
  currency: string;
  lock_before_minutes: number;
  visibility: SessionVisibility;
  status: TemplateStatus;
}>;

export type OwnerSessionCreatePayload = {
  resource_id: string;
  name: string;
  description?: string;
  mode: 'scheduled' | 'open';
  sport: string;
  starts_at: string;
  ends_at: string;
  timezone?: string;
  min_participants: number;
  max_participants: number;
  pricing_model: SessionPricingModel;
  price_total_minor?: number;
  price_per_person_minor?: number;
  currency?: string;
  lock_before_minutes?: number;
  visibility?: SessionVisibility;
};
