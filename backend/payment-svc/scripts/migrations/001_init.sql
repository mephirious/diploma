-- Payment Service Database Schema

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL,
    user_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    stripe_payment_intent_id VARCHAR(255) UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED' 
        CHECK (status IN ('CREATED', 'PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'REFUNDED')),
    failure_reason TEXT,
    refund_id VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_session_id ON payments(session_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_stripe_payment_intent_id ON payments(stripe_payment_intent_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Audit log for payment state transitions
CREATE TABLE IF NOT EXISTS payment_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_audit_log_payment_id ON payment_audit_log(payment_id);

COMMENT ON TABLE payments IS 'Payment records for session participants';
COMMENT ON TABLE payment_audit_log IS 'Audit trail of payment status changes';
COMMENT ON COLUMN payments.session_id IS 'Reference to session from session-svc';
COMMENT ON COLUMN payments.user_id IS 'Reference to user from auth-svc';
COMMENT ON COLUMN payments.stripe_payment_intent_id IS 'Stripe PaymentIntent ID';

