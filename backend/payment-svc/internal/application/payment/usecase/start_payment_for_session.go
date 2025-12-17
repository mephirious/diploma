package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/payment-svc/internal/application/payment/dto"
	"github.com/diploma/payment-svc/internal/domain/payment/port"
	"github.com/diploma/payment-svc/internal/domain/payment/service"
)

type StartPaymentForSessionUseCase struct {
	paymentService *service.PaymentService
	stripeClient   port.StripeClient
	eventPublisher EventPublisher
}

func NewStartPaymentForSessionUseCase(
	paymentService *service.PaymentService,
	stripeClient port.StripeClient,
	eventPublisher EventPublisher,
) *StartPaymentForSessionUseCase {
	return &StartPaymentForSessionUseCase{
		paymentService: paymentService,
		stripeClient:   stripeClient,
		eventPublisher: eventPublisher,
	}
}

func (uc *StartPaymentForSessionUseCase) Execute(ctx context.Context, input dto.StartPaymentForSessionInput) (*dto.StartPaymentForSessionOutput, error) {
	payment, err := uc.paymentService.CreatePayment(
		ctx,
		input.SessionID,
		input.UserID,
		input.Amount,
		input.Currency,
	)
	if err != nil {
		return nil, err
	}

	stripeInput := port.CreatePaymentIntentInput{
		Amount:      int64(input.Amount * 100), // Convert to cents
		Currency:    input.Currency,
		Description: fmt.Sprintf("Payment for session %s", input.SessionID),
		Metadata: map[string]string{
			"payment_id": payment.ID.String(),
			"session_id": input.SessionID.String(),
			"user_id":    input.UserID.String(),
		},
	}

	stripeOutput, err := uc.stripeClient.CreatePaymentIntent(ctx, stripeInput)
	if err != nil {
		return nil, err
	}

	if err := payment.MarkPending(stripeOutput.PaymentIntentID); err != nil {
		return nil, err
	}

	if err := uc.paymentService.UpdatePaymentStatus(ctx, payment); err != nil {
		return nil, err
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishPaymentCreated(ctx, payment.ID, payment.SessionID, payment.UserID, payment.Amount)
	}

	return &dto.StartPaymentForSessionOutput{
		PaymentID:    payment.ID,
		ClientSecret: stripeOutput.ClientSecret,
		Amount:       payment.Amount,
		Currency:     payment.Currency,
	}, nil
}

