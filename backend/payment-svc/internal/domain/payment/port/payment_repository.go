package port

import (
	"context"

	"github.com/diploma/payment-svc/internal/domain/payment/entity"
	"github.com/google/uuid"
)

type PaymentRepository interface {
	Create(ctx context.Context, payment *entity.Payment) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Payment, error)
	GetByStripePaymentIntentID(ctx context.Context, stripeID string) (*entity.Payment, error)
	ListBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Payment, error)
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Payment, error)
	Update(ctx context.Context, payment *entity.Payment) error
}

