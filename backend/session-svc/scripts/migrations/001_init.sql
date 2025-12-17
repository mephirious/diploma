-- Session Service Database Schema

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL UNIQUE,
    host_id UUID NOT NULL,
    sport_type VARCHAR(100) NOT NULL,
    skill_level VARCHAR(50),
    max_participants INT NOT NULL CHECK (max_participants > 0),
    min_participants INT NOT NULL CHECK (min_participants > 0),
    current_participants INT NOT NULL DEFAULT 0 CHECK (current_participants >= 0),
    price_per_participant DECIMAL(10, 2) NOT NULL CHECK (price_per_participant >= 0),
    visibility VARCHAR(20) NOT NULL DEFAULT 'PUBLIC' CHECK (visibility IN ('PUBLIC', 'PRIVATE')),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'FULL', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT min_max_check CHECK (min_participants <= max_participants)
);

CREATE INDEX idx_sessions_reservation_id ON sessions(reservation_id);
CREATE INDEX idx_sessions_host_id ON sessions(host_id);
CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_visibility ON sessions(visibility);
CREATE INDEX idx_sessions_sport_type ON sessions(sport_type);
CREATE INDEX idx_sessions_skill_level ON sessions(skill_level);

-- Session participants table
CREATE TABLE IF NOT EXISTS session_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('HOST', 'PLAYER')),
    status VARCHAR(20) NOT NULL DEFAULT 'JOINED' CHECK (status IN ('JOINED', 'LEFT', 'REMOVED')),
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_session_participants_session_id ON session_participants(session_id);
CREATE INDEX idx_session_participants_user_id ON session_participants(user_id);
CREATE INDEX idx_session_participants_status ON session_participants(status);
CREATE UNIQUE INDEX idx_session_participants_unique_active ON session_participants(session_id, user_id) 
    WHERE status = 'JOINED';

COMMENT ON TABLE sessions IS 'Game sessions on top of reservations for matchmaking';
COMMENT ON TABLE session_participants IS 'Users participating in sessions';
COMMENT ON COLUMN sessions.reservation_id IS 'Reference to reservation from reservation-svc';
COMMENT ON COLUMN sessions.host_id IS 'User who created the session';
COMMENT ON COLUMN sessions.current_participants IS 'Current number of active participants';

