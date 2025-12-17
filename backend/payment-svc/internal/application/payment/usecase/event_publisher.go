package usecase

import (
	"context"

	"github.com/google/uuid"
)

type EventPublisher interface {
	PublishPaymentCreated(ctx context.Context, paymentID, sessionID, userID uuid.UUID, amount float64) error
	PublishPaymentSucceeded(ctx context.Context, paymentID, sessionID, userID uuid.UUID, amount float64) error
	PublishPaymentFailed(ctx context.Context, paymentID, sessionID, userID uuid.UUID, reason string) error
	PublishPaymentRefunded(ctx context.Context, paymentID, sessionID, userID uuid.UUID, refundID string) error
}

