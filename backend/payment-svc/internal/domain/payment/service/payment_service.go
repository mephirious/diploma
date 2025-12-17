package service

import (
	"context"
	"fmt"

	"github.com/diploma/payment-svc/internal/domain/payment/entity"
	"github.com/diploma/payment-svc/internal/domain/payment/port"
	pkgerrors "github.com/diploma/payment-svc/pkg/errors"
	"github.com/google/uuid"
)

type PaymentService struct {
	repo port.PaymentRepository
}

func NewPaymentService(repo port.PaymentRepository) *PaymentService {
	return &PaymentService{repo: repo}
}

func (s *PaymentService) CreatePayment(ctx context.Context, sessionID, userID uuid.UUID, amount float64, currency string) (*entity.Payment, error) {
	payment := &entity.Payment{
		ID:        uuid.New(),
		SessionID: sessionID,
		UserID:    userID,
		Amount:    amount,
		Currency:  currency,
		Status:    entity.PaymentStatusCreated,
	}

	if err := payment.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Create(ctx, payment); err != nil {
		return nil, fmt.Errorf("failed to create payment: %w", err)
	}

	return payment, nil
}

func (s *PaymentService) GetPayment(ctx context.Context, id uuid.UUID) (*entity.Payment, error) {
	if id == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("payment_id is required")
	}
	return s.repo.GetByID(ctx, id)
}

func (s *PaymentService) GetByStripePaymentIntentID(ctx context.Context, stripeID string) (*entity.Payment, error) {
	if stripeID == "" {
		return nil, pkgerrors.NewInvalidArgumentError("stripe_payment_intent_id is required")
	}
	return s.repo.GetByStripePaymentIntentID(ctx, stripeID)
}

func (s *PaymentService) UpdatePaymentStatus(ctx context.Context, payment *entity.Payment) error {
	return s.repo.Update(ctx, payment)
}

func (s *PaymentService) ListPaymentsBySession(ctx context.Context, sessionID uuid.UUID) ([]*entity.Payment, error) {
	if sessionID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	return s.repo.ListBySessionID(ctx, sessionID)
}

func (s *PaymentService) ListPaymentsByUser(ctx context.Context, userID uuid.UUID) ([]*entity.Payment, error) {
	if userID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("user_id is required")
	}
	return s.repo.ListByUserID(ctx, userID)
}

