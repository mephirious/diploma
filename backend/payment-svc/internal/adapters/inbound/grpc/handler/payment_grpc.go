package handler

import (
	"context"

	paymentv1 "github.com/diploma/payment-svc/api/v1"
	"github.com/diploma/payment-svc/internal/application/payment/usecase"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type PaymentGRPCHandler struct {
	paymentv1.UnimplementedPaymentServiceServer
	startPaymentUseCase  *usecase.StartPaymentForSessionUseCase
	handleWebhookUseCase *usecase.HandleStripeWebhookUseCase
}

func NewPaymentGRPCHandler(
	startPaymentUseCase *usecase.StartPaymentForSessionUseCase,
	handleWebhookUseCase *usecase.HandleStripeWebhookUseCase,
) *PaymentGRPCHandler {
	return &PaymentGRPCHandler{
		startPaymentUseCase:  startPaymentUseCase,
		handleWebhookUseCase: handleWebhookUseCase,
	}
}

func (h *PaymentGRPCHandler) StartPaymentForSession(ctx context.Context, req *paymentv1.StartPaymentForSessionRequest) (*paymentv1.StartPaymentForSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *PaymentGRPCHandler) GetPaymentsBySession(ctx context.Context, req *paymentv1.GetPaymentsBySessionRequest) (*paymentv1.GetPaymentsBySessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *PaymentGRPCHandler) GetPayment(ctx context.Context, req *paymentv1.GetPaymentRequest) (*paymentv1.GetPaymentResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *PaymentGRPCHandler) GetPaymentsByUser(ctx context.Context, req *paymentv1.GetPaymentsByUserRequest) (*paymentv1.GetPaymentsByUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *PaymentGRPCHandler) RefundPayment(ctx context.Context, req *paymentv1.RefundPaymentRequest) (*paymentv1.RefundPaymentResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

