CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Reservation status enum
CREATE TYPE reservation_status AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED');

-- Reservations table
-- NOTE: To prevent double-booking in a real booking system, you would typically:
-- 1. Add start_time and end_time columns
-- 2. Add an exclusion constraint using btree_gist:
--    EXCLUDE USING gist (
--      apartment_id WITH =,
--      tstzrange(start_time, end_time) WITH &&
--    ) WHERE (status IN ('PENDING', 'CONFIRMED'))
-- 3. This ensures no overlapping time slots for the same apartment
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    apartment_id UUID NOT NULL,
    status reservation_status NOT NULL DEFAULT 'PENDING',
    reserved_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ,
    comment TEXT
);

-- Indexes for query optimization
CREATE INDEX idx_reservations_user_id ON reservations(user_id);
CREATE INDEX idx_reservations_apartment_id ON reservations(apartment_id);
CREATE INDEX idx_reservations_status ON reservations(status);

-- Additional indexes for future time-based queries
CREATE INDEX idx_reservations_reserved_at ON reservations(reserved_at DESC);

-- NOTE: For production booking systems, consider:
-- 1. Adding optimistic locking with version column
-- 2. Using Redis for temporary reservation holds (5-15 minutes)
-- 3. Implementing reservation expiry job
-- 4. Adding transaction isolation level SERIALIZABLE for critical sections

