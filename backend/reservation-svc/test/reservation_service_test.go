package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
	"github.com/google/uuid"
)

type MockReservationRepository struct {
	reservations map[uuid.UUID]*entity.Reservation
}

func NewMockReservationRepository() *MockReservationRepository {
	return &MockReservationRepository{
		reservations: make(map[uuid.UUID]*entity.Reservation),
	}
}

func (m *MockReservationRepository) Create(ctx context.Context, reservation *entity.Reservation) error {
	m.reservations[reservation.ID] = reservation
	reservation.ReservedAt = time.Now()
	return nil
}

func (m *MockReservationRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	reservation, ok := m.reservations[id]
	if !ok {
		return nil, fmt.Errorf("reservation not found")
	}
	return reservation, nil
}

func (m *MockReservationRepository) Update(ctx context.Context, reservation *entity.Reservation) error {
	if _, ok := m.reservations[reservation.ID]; !ok {
		return fmt.Errorf("reservation not found")
	}
	m.reservations[reservation.ID] = reservation
	return nil
}

func (m *MockReservationRepository) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	var result []*entity.Reservation
	for _, reservation := range m.reservations {
		if reservation.UserID == userID {
			result = append(result, reservation)
		}
	}
	return result, nil
}

func TestCreateReservation(t *testing.T) {
	repo := NewMockReservationRepository()
	service := service.NewReservationService(repo)

	userID := uuid.New()
	apartmentID := uuid.New()
	comment := "Test comment"

	reservation, err := service.CreateReservation(context.Background(), userID, apartmentID, &comment)
	if err != nil {
		t.Fatalf("Failed to create reservation: %v", err)
	}

	if reservation.ID == uuid.Nil {
		t.Error("Reservation ID should not be nil")
	}

	if reservation.Status != entity.StatusPending {
		t.Errorf("Expected status PENDING, got %s", reservation.Status)
	}

	if reservation.UserID != userID {
		t.Errorf("Expected user_id %s, got %s", userID, reservation.UserID)
	}
}

func TestConfirmReservation(t *testing.T) {
	repo := NewMockReservationRepository()
	service := service.NewReservationService(repo)

	userID := uuid.New()
	apartmentID := uuid.New()

	reservation, err := service.CreateReservation(context.Background(), userID, apartmentID, nil)
	if err != nil {
		t.Fatalf("Failed to create reservation: %v", err)
	}

	if err := service.ConfirmReservation(context.Background(), reservation.ID); err != nil {
		t.Fatalf("Failed to confirm reservation: %v", err)
	}

	updated, err := service.GetReservation(context.Background(), reservation.ID)
	if err != nil {
		t.Fatalf("Failed to get reservation: %v", err)
	}

	if updated.Status != entity.StatusConfirmed {
		t.Errorf("Expected status CONFIRMED, got %s", updated.Status)
	}
}

func TestCancelReservation(t *testing.T) {
	repo := NewMockReservationRepository()
	service := service.NewReservationService(repo)

	userID := uuid.New()
	apartmentID := uuid.New()

	reservation, err := service.CreateReservation(context.Background(), userID, apartmentID, nil)
	if err != nil {
		t.Fatalf("Failed to create reservation: %v", err)
	}

	if err := service.CancelReservation(context.Background(), reservation.ID); err != nil {
		t.Fatalf("Failed to cancel reservation: %v", err)
	}

	updated, err := service.GetReservation(context.Background(), reservation.ID)
	if err != nil {
		t.Fatalf("Failed to get reservation: %v", err)
	}

	if updated.Status != entity.StatusCancelled {
		t.Errorf("Expected status CANCELLED, got %s", updated.Status)
	}
}

func TestReservationStatusTransitions(t *testing.T) {
	repo := NewMockReservationRepository()
	service := service.NewReservationService(repo)

	userID := uuid.New()
	apartmentID := uuid.New()

	reservation, _ := service.CreateReservation(context.Background(), userID, apartmentID, nil)

	if err := service.ConfirmReservation(context.Background(), reservation.ID); err != nil {
		t.Fatalf("Should be able to confirm PENDING reservation: %v", err)
	}

	if err := service.CancelReservation(context.Background(), reservation.ID); err != nil {
		t.Fatalf("Should be able to cancel CONFIRMED reservation: %v", err)
	}

	if err := service.ConfirmReservation(context.Background(), reservation.ID); err == nil {
		t.Error("Should not be able to confirm CANCELLED reservation")
	}
}

