package entity

import (
	"time"

	pkgerrors "github.com/diploma/payment-svc/pkg/errors"
	"github.com/google/uuid"
)

type PaymentStatus string

const (
	PaymentStatusCreated    PaymentStatus = "CREATED"
	PaymentStatusPending    PaymentStatus = "PENDING"
	PaymentStatusProcessing PaymentStatus = "PROCESSING"
	PaymentStatusSucceeded  PaymentStatus = "SUCCEEDED"
	PaymentStatusFailed     PaymentStatus = "FAILED"
	PaymentStatusRefunded   PaymentStatus = "REFUNDED"
)

type Payment struct {
	ID                    uuid.UUID
	SessionID             uuid.UUID
	UserID                uuid.UUID
	Amount                float64
	Currency              string
	StripePaymentIntentID string
	Status                PaymentStatus
	FailureReason         string
	RefundID              string
	CreatedAt             time.Time
	UpdatedAt             time.Time
}

func (p *Payment) IsValid() error {
	if p.SessionID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	if p.UserID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("user_id is required")
	}
	if p.Amount <= 0 {
		return pkgerrors.NewInvalidArgumentError("amount must be positive")
	}
	if p.Currency == "" {
		return pkgerrors.NewInvalidArgumentError("currency is required")
	}
	return nil
}

func (p *Payment) CanTransitionTo(newStatus PaymentStatus) error {
	switch p.Status {
	case PaymentStatusCreated:
		if newStatus != PaymentStatusPending {
			return pkgerrors.NewFailedPreconditionError("can only transition from CREATED to PENDING")
		}
	case PaymentStatusPending:
		if newStatus != PaymentStatusProcessing && newStatus != PaymentStatusFailed {
			return pkgerrors.NewFailedPreconditionError("can only transition from PENDING to PROCESSING or FAILED")
		}
	case PaymentStatusProcessing:
		if newStatus != PaymentStatusSucceeded && newStatus != PaymentStatusFailed {
			return pkgerrors.NewFailedPreconditionError("can only transition from PROCESSING to SUCCEEDED or FAILED")
		}
	case PaymentStatusSucceeded:
		if newStatus != PaymentStatusRefunded {
			return pkgerrors.NewFailedPreconditionError("can only transition from SUCCEEDED to REFUNDED")
		}
	case PaymentStatusFailed:
		return pkgerrors.NewFailedPreconditionError("cannot transition from FAILED status")
	case PaymentStatusRefunded:
		return pkgerrors.NewFailedPreconditionError("cannot transition from REFUNDED status")
	}
	return nil
}

func (p *Payment) MarkPending(stripePaymentIntentID string) error {
	if err := p.CanTransitionTo(PaymentStatusPending); err != nil {
		return err
	}
	p.Status = PaymentStatusPending
	p.StripePaymentIntentID = stripePaymentIntentID
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Payment) MarkProcessing() error {
	if err := p.CanTransitionTo(PaymentStatusProcessing); err != nil {
		return err
	}
	p.Status = PaymentStatusProcessing
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Payment) MarkSucceeded() error {
	if err := p.CanTransitionTo(PaymentStatusSucceeded); err != nil {
		return err
	}
	p.Status = PaymentStatusSucceeded
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Payment) MarkFailed(reason string) error {
	if p.Status != PaymentStatusPending && p.Status != PaymentStatusProcessing {
		return pkgerrors.NewFailedPreconditionError("can only fail from PENDING or PROCESSING status")
	}
	p.Status = PaymentStatusFailed
	p.FailureReason = reason
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Payment) MarkRefunded(refundID string) error {
	if err := p.CanTransitionTo(PaymentStatusRefunded); err != nil {
		return err
	}
	p.Status = PaymentStatusRefunded
	p.RefundID = refundID
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Payment) IsSucceeded() bool {
	return p.Status == PaymentStatusSucceeded
}

func (p *Payment) IsFinal() bool {
	return p.Status == PaymentStatusSucceeded || p.Status == PaymentStatusFailed || p.Status == PaymentStatusRefunded
}

