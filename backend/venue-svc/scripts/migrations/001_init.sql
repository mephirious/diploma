-- Venue Service Database Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Venues table
CREATE TABLE IF NOT EXISTS venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(500) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index for querying venues by city
CREATE INDEX idx_venues_city ON venues(city);

-- Index for querying venues by owner
CREATE INDEX idx_venues_owner_id ON venues(owner_id);

-- Resources table (courts, fields, etc.)
CREATE TABLE IF NOT EXISTS resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sport_type VARCHAR(100) NOT NULL,  -- tennis, football, basketball, etc.
    capacity INT NOT NULL CHECK (capacity > 0),
    surface_type VARCHAR(100),         -- grass, clay, hardcourt, etc.
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index for querying resources by venue
CREATE INDEX idx_resources_venue_id ON resources(venue_id);

-- Index for querying active resources
CREATE INDEX idx_resources_is_active ON resources(is_active);

-- Schedule slots table (opening hours and pricing)
CREATE TABLE IF NOT EXISTS schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    resource_id UUID NOT NULL REFERENCES resources(id) ON DELETE CASCADE,
    day_of_week INT NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
    start_time VARCHAR(5) NOT NULL,   -- HH:MM format
    end_time VARCHAR(5) NOT NULL,     -- HH:MM format
    base_price DECIMAL(10, 2) NOT NULL CHECK (base_price >= 0)
);

-- Index for querying schedule slots by resource
CREATE INDEX idx_schedule_slots_resource_id ON schedule_slots(resource_id);

-- Unique constraint to prevent duplicate time slots for the same resource
CREATE UNIQUE INDEX idx_schedule_slots_unique ON schedule_slots(resource_id, day_of_week, start_time);

-- Comments for documentation
COMMENT ON TABLE venues IS 'Sports venues/facilities';
COMMENT ON TABLE resources IS 'Bookable resources (courts, fields) within venues';
COMMENT ON TABLE schedule_slots IS 'Opening hours and base pricing for resources';

COMMENT ON COLUMN venues.owner_id IS 'Reference to user_id from auth-svc';
COMMENT ON COLUMN resources.sport_type IS 'Type of sport (tennis, football, basketball, etc.)';
COMMENT ON COLUMN resources.surface_type IS 'Surface material (grass, clay, hardcourt, etc.)';
COMMENT ON COLUMN schedule_slots.day_of_week IS '0=Sunday through 6=Saturday';
COMMENT ON COLUMN schedule_slots.start_time IS 'Time in HH:MM format (24-hour)';
COMMENT ON COLUMN schedule_slots.end_time IS 'Time in HH:MM format (24-hour)';
COMMENT ON COLUMN schedule_slots.base_price IS 'Base hourly rate for the time slot';

