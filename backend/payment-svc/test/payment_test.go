package test

import (
	"context"
	"testing"
	"time"

	"github.com/diploma/payment-svc/internal/domain/payment/entity"
	"github.com/diploma/payment-svc/internal/domain/payment/port"
	"github.com/diploma/payment-svc/internal/domain/payment/service"
	"github.com/google/uuid"
)

type MockPaymentRepo struct {
	payments map[uuid.UUID]*entity.Payment
}

func NewMockPaymentRepo() *MockPaymentRepo {
	return &MockPaymentRepo{payments: make(map[uuid.UUID]*entity.Payment)}
}

func (m *MockPaymentRepo) Create(ctx context.Context, p *entity.Payment) error {
	m.payments[p.ID] = p
	return nil
}

func (m *MockPaymentRepo) GetByID(ctx context.Context, id uuid.UUID) (*entity.Payment, error) {
	if p, ok := m.payments[id]; ok {
		return p, nil
	}
	return nil, nil
}

func (m *MockPaymentRepo) Update(ctx context.Context, p *entity.Payment) error {
	m.payments[p.ID] = p
	return nil
}

func (m *MockPaymentRepo) GetByStripePaymentIntentID(ctx context.Context, stripeID string) (*entity.Payment, error) {
	for _, p := range m.payments {
		if p.StripePaymentIntentID == stripeID {
			return p, nil
		}
	}
	return nil, nil
}

func (m *MockPaymentRepo) ListBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Payment, error) {
	var result []*entity.Payment
	for _, p := range m.payments {
		if p.SessionID == sessionID {
			result = append(result, p)
		}
	}
	return result, nil
}

func (m *MockPaymentRepo) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Payment, error) {
	var result []*entity.Payment
	for _, p := range m.payments {
		if p.UserID == userID {
			result = append(result, p)
		}
	}
	return result, nil
}

type MockStripeClient struct{}

func (m *MockStripeClient) CreatePaymentIntent(ctx context.Context, input port.CreatePaymentIntentInput) (*port.CreatePaymentIntentOutput, error) {
	return &port.CreatePaymentIntentOutput{
		PaymentIntentID: "pi_test_" + uuid.New().String(),
		ClientSecret:    "secret_test_" + uuid.New().String(),
	}, nil
}

func (m *MockStripeClient) CreateRefund(ctx context.Context, input port.RefundInput) (*port.RefundOutput, error) {
	return &port.RefundOutput{
		RefundID: "re_test_" + uuid.New().String(),
	}, nil
}

var _ port.PaymentRepository = (*MockPaymentRepo)(nil)
var _ port.StripeClient = (*MockStripeClient)(nil)

func TestCreatePayment(t *testing.T) {
	repo := NewMockPaymentRepo()
	svc := service.NewPaymentService(repo)

	ctx := context.Background()
	payment, err := svc.CreatePayment(ctx, uuid.New(), uuid.New(), 15.0, "USD")

	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if payment.ID == uuid.Nil {
		t.Error("Expected valid payment ID")
	}

	if payment.Status != entity.PaymentStatusCreated {
		t.Errorf("Expected status CREATED, got %v", payment.Status)
	}

	if payment.Amount != 15.0 {
		t.Errorf("Expected amount 15.0, got %f", payment.Amount)
	}
}

func TestPaymentStateTransitions(t *testing.T) {
	payment := &entity.Payment{
		ID:        uuid.New(),
		SessionID: uuid.New(),
		UserID:    uuid.New(),
		Amount:    20.0,
		Currency:  "USD",
		Status:    entity.PaymentStatusCreated,
		CreatedAt: time.Now(),
	}

	stripeID := "pi_test_123"
	err := payment.MarkPending(stripeID)
	if err != nil {
		t.Fatalf("Expected no error marking pending, got %v", err)
	}

	if payment.Status != entity.PaymentStatusPending {
		t.Errorf("Expected status PENDING, got %v", payment.Status)
	}

	if payment.StripePaymentIntentID != stripeID {
		t.Error("Expected Stripe ID to be set")
	}

	payment.Status = entity.PaymentStatusProcessing
	err = payment.MarkSucceeded()
	if err != nil {
		t.Fatalf("Expected no error marking succeeded, got %v", err)
	}

	if payment.Status != entity.PaymentStatusSucceeded {
		t.Errorf("Expected status SUCCEEDED, got %v", payment.Status)
	}
}

func TestPaymentValidation(t *testing.T) {
	tests := []struct {
		name      string
		payment   *entity.Payment
		expectErr bool
	}{
		{
			name: "Valid payment",
			payment: &entity.Payment{
				ID:        uuid.New(),
				SessionID: uuid.New(),
				UserID:    uuid.New(),
				Amount:    10.0,
				Currency:  "USD",
				Status:    entity.PaymentStatusCreated,
			},
			expectErr: false,
		},
		{
			name: "Zero amount",
			payment: &entity.Payment{
				ID:        uuid.New(),
				SessionID: uuid.New(),
				UserID:    uuid.New(),
				Amount:    0,
				Currency:  "USD",
				Status:    entity.PaymentStatusCreated,
			},
			expectErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.payment.IsValid()
			if tt.expectErr && err == nil {
				t.Error("Expected error but got none")
			}
			if !tt.expectErr && err != nil {
				t.Errorf("Expected no error but got: %v", err)
			}
		})
	}
}

