package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/payment-svc/internal/domain/payment/service"
	pkgerrors "github.com/diploma/payment-svc/pkg/errors"
)

type HandleStripeWebhookUseCase struct {
	paymentService *service.PaymentService
	eventPublisher EventPublisher
}

func NewHandleStripeWebhookUseCase(
	paymentService *service.PaymentService,
	eventPublisher EventPublisher,
) *HandleStripeWebhookUseCase {
	return &HandleStripeWebhookUseCase{
		paymentService: paymentService,
		eventPublisher: eventPublisher,
	}
}

func (uc *HandleStripeWebhookUseCase) HandlePaymentIntentSucceeded(ctx context.Context, stripePaymentIntentID string) error {
	payment, err := uc.paymentService.GetByStripePaymentIntentID(ctx, stripePaymentIntentID)
	if err != nil {
		return err
	}

	if err := payment.MarkSucceeded(); err != nil {
		return err
	}

	if err := uc.paymentService.UpdatePaymentStatus(ctx, payment); err != nil {
		return fmt.Errorf("failed to update payment status: %w", err)
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishPaymentSucceeded(ctx, payment.ID, payment.SessionID, payment.UserID, payment.Amount)
	}

	return nil
}

func (uc *HandleStripeWebhookUseCase) HandlePaymentIntentFailed(ctx context.Context, stripePaymentIntentID string, reason string) error {
	payment, err := uc.paymentService.GetByStripePaymentIntentID(ctx, stripePaymentIntentID)
	if err != nil {
		return err
	}

	if err := payment.MarkFailed(reason); err != nil {
		return err
	}

	if err := uc.paymentService.UpdatePaymentStatus(ctx, payment); err != nil {
		return fmt.Errorf("failed to update payment status: %w", err)
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishPaymentFailed(ctx, payment.ID, payment.SessionID, payment.UserID, reason)
	}

	return nil
}

func (uc *HandleStripeWebhookUseCase) HandlePaymentIntentProcessing(ctx context.Context, stripePaymentIntentID string) error {
	payment, err := uc.paymentService.GetByStripePaymentIntentID(ctx, stripePaymentIntentID)
	if err != nil {
		return err
	}

	if err := payment.MarkProcessing(); err != nil {
		if pkgerrors.GetErrorCode(err) == pkgerrors.CodeFailedPrecondition {
			return nil
		}
		return err
	}

	return uc.paymentService.UpdatePaymentStatus(ctx, payment)
}

