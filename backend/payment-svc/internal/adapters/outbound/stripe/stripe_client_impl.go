package stripe

import (
	"context"

	"github.com/diploma/payment-svc/internal/domain/payment/port"
	pkgerrors "github.com/diploma/payment-svc/pkg/errors"
	"github.com/stripe/stripe-go/v76"
	"github.com/stripe/stripe-go/v76/paymentintent"
	"github.com/stripe/stripe-go/v76/refund"
)

type StripeClientImpl struct {
	apiKey string
}

func NewStripeClient(apiKey string) *StripeClientImpl {
	stripe.Key = apiKey
	return &StripeClientImpl{apiKey: apiKey}
}

func (c *StripeClientImpl) CreatePaymentIntent(ctx context.Context, input port.CreatePaymentIntentInput) (*port.CreatePaymentIntentOutput, error) {
	params := &stripe.PaymentIntentParams{
		Amount:      stripe.Int64(input.Amount),
		Currency:    stripe.String(input.Currency),
		Description: stripe.String(input.Description),
	}

	if input.Metadata != nil {
		params.Metadata = input.Metadata
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		return nil, pkgerrors.NewExternalAPIError("failed to create payment intent", err)
	}

	return &port.CreatePaymentIntentOutput{
		PaymentIntentID: pi.ID,
		ClientSecret:    pi.ClientSecret,
	}, nil
}

func (c *StripeClientImpl) CreateRefund(ctx context.Context, input port.RefundInput) (*port.RefundOutput, error) {
	params := &stripe.RefundParams{
		PaymentIntent: stripe.String(input.PaymentIntentID),
	}

	if input.Reason != "" {
		params.Reason = stripe.String(input.Reason)
	}

	r, err := refund.New(params)
	if err != nil {
		return nil, pkgerrors.NewExternalAPIError("failed to create refund", err)
	}

	return &port.RefundOutput{
		RefundID: r.ID,
	}, nil
}

