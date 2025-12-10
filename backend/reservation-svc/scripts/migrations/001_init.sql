CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE reservation_status AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED');

CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    apartment_id UUID NOT NULL,
    status reservation_status NOT NULL DEFAULT 'PENDING',
    reserved_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ,
    comment TEXT
);

CREATE INDEX idx_reservations_user_id ON reservations(user_id);
CREATE INDEX idx_reservations_apartment_id ON reservations(apartment_id);
CREATE INDEX idx_reservations_status ON reservations(status);

