package dto

import (
	"time"

	"github.com/diploma/payment-svc/internal/domain/payment/entity"
	"github.com/google/uuid"
)

type StartPaymentForSessionInput struct {
	SessionID uuid.UUID
	UserID    uuid.UUID
	Amount    float64
	Currency  string
}

type StartPaymentForSessionOutput struct {
	PaymentID    uuid.UUID
	ClientSecret string
	Amount       float64
	Currency     string
}

type GetPaymentInput struct {
	PaymentID uuid.UUID
}

type GetPaymentOutput struct {
	ID                    uuid.UUID
	SessionID             uuid.UUID
	UserID                uuid.UUID
	Amount                float64
	Currency              string
	StripePaymentIntentID string
	Status                entity.PaymentStatus
	CreatedAt             time.Time
	UpdatedAt             time.Time
}

type RefundPaymentInput struct {
	PaymentID uuid.UUID
	Reason    string
}

type RefundPaymentOutput struct {
	Success  bool
	RefundID string
}

func ToPaymentOutput(payment *entity.Payment) GetPaymentOutput {
	return GetPaymentOutput{
		ID:                    payment.ID,
		SessionID:             payment.SessionID,
		UserID:                payment.UserID,
		Amount:                payment.Amount,
		Currency:              payment.Currency,
		StripePaymentIntentID: payment.StripePaymentIntentID,
		Status:                payment.Status,
		CreatedAt:             payment.CreatedAt,
		UpdatedAt:             payment.UpdatedAt,
	}
}

