package port

import "context"

type CreatePaymentIntentInput struct {
	Amount      int64
	Currency    string
	Description string
	Metadata    map[string]string
}

type CreatePaymentIntentOutput struct {
	PaymentIntentID string
	ClientSecret    string
}

type RefundInput struct {
	PaymentIntentID string
	Reason          string
}

type RefundOutput struct {
	RefundID string
}

type StripeClient interface {
	CreatePaymentIntent(ctx context.Context, input CreatePaymentIntentInput) (*CreatePaymentIntentOutput, error)
	CreateRefund(ctx context.Context, input RefundInput) (*RefundOutput, error)
}

