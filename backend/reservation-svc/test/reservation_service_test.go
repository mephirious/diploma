package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/application/reservation/usecase"
	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
	pkgerrors "github.com/diploma/reservation-svc/pkg/errors"
	"github.com/google/uuid"
)

type MockReservationRepository struct {
	reservations map[uuid.UUID]*entity.Reservation
	shouldError  bool
}

func NewMockReservationRepository() *MockReservationRepository {
	return &MockReservationRepository{
		reservations: make(map[uuid.UUID]*entity.Reservation),
	}
}

func (m *MockReservationRepository) Create(ctx context.Context, reservation *entity.Reservation) error {
	if m.shouldError {
		return fmt.Errorf("database error")
	}
	
	m.reservations[reservation.ID] = reservation
	reservation.ReservedAt = time.Now()
	return nil
}

func (m *MockReservationRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	if m.shouldError {
		return nil, fmt.Errorf("database error")
	}
	
	reservation, ok := m.reservations[id]
	if !ok {
		return nil, pkgerrors.NewNotFoundError("reservation not found")
	}
	return reservation, nil
}

func (m *MockReservationRepository) Update(ctx context.Context, reservation *entity.Reservation) error {
	if m.shouldError {
		return fmt.Errorf("database error")
	}
	
	if _, ok := m.reservations[reservation.ID]; !ok {
		return pkgerrors.NewNotFoundError("reservation not found")
	}
	m.reservations[reservation.ID] = reservation
	return nil
}

func (m *MockReservationRepository) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	if m.shouldError {
		return nil, fmt.Errorf("database error")
	}
	
	var result []*entity.Reservation
	for _, reservation := range m.reservations {
		if reservation.UserID == userID {
			result = append(result, reservation)
		}
	}
	return result, nil
}

type MockEventPublisher struct {
	CreatedEvents   []string
	ConfirmedEvents []string
	CancelledEvents []string
	shouldError     bool
}

func NewMockEventPublisher() *MockEventPublisher {
	return &MockEventPublisher{
		CreatedEvents:   make([]string, 0),
		ConfirmedEvents: make([]string, 0),
		CancelledEvents: make([]string, 0),
	}
}

func (m *MockEventPublisher) PublishReservationCreated(ctx context.Context, reservationID, userID, apartmentID string) error {
	if m.shouldError {
		return fmt.Errorf("event publish error")
	}
	m.CreatedEvents = append(m.CreatedEvents, reservationID)
	return nil
}

func (m *MockEventPublisher) PublishReservationConfirmed(ctx context.Context, reservationID string) error {
	if m.shouldError {
		return fmt.Errorf("event publish error")
	}
	m.ConfirmedEvents = append(m.ConfirmedEvents, reservationID)
	return nil
}

func (m *MockEventPublisher) PublishReservationCancelled(ctx context.Context, reservationID string) error {
	if m.shouldError {
		return fmt.Errorf("event publish error")
	}
	m.CancelledEvents = append(m.CancelledEvents, reservationID)
	return nil
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

	if _, err := service.ConfirmReservation(context.Background(), reservation.ID); err != nil {
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

	if _, err := service.CancelReservation(context.Background(), reservation.ID); err != nil {
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
	svc := service.NewReservationService(repo)

	userID := uuid.New()
	apartmentID := uuid.New()

	reservation, _ := svc.CreateReservation(context.Background(), userID, apartmentID, nil)

	_, err := svc.ConfirmReservation(context.Background(), reservation.ID)
	if err != nil {
		t.Fatalf("Should be able to confirm PENDING reservation: %v", err)
	}

	_, err = svc.CancelReservation(context.Background(), reservation.ID)
	if err != nil {
		t.Fatalf("Should be able to cancel CONFIRMED reservation: %v", err)
	}

	_, err = svc.ConfirmReservation(context.Background(), reservation.ID)
	if err == nil {
		t.Error("Should not be able to confirm CANCELLED reservation")
	}
	
	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeFailedPrecondition {
		t.Errorf("Expected FailedPrecondition error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestCreateReservationSuccess(t *testing.T) {
	repo := NewMockReservationRepository()
	eventPublisher := NewMockEventPublisher()
	svc := service.NewReservationService(repo)
	createUseCase := usecase.NewCreateReservationUseCase(svc, eventPublisher)

	userID := uuid.New()
	apartmentID := uuid.New()
	comment := "Test reservation"

	input := dto.CreateReservationInput{
		UserID:      userID,
		ApartmentID: apartmentID,
		Comment:     &comment,
	}

	output, err := createUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("Failed to create reservation: %v", err)
	}

	if output.ReservationID == uuid.Nil {
		t.Error("Expected reservation ID to be set")
	}

	if len(eventPublisher.CreatedEvents) != 1 {
		t.Errorf("Expected 1 created event, got %d", len(eventPublisher.CreatedEvents))
	}

	stored, err := repo.GetByID(context.Background(), output.ReservationID)
	if err != nil {
		t.Fatalf("Failed to retrieve reservation: %v", err)
	}

	if stored.Status != entity.StatusPending {
		t.Errorf("Expected status PENDING, got %s", stored.Status)
	}
	if stored.UserID != userID {
		t.Errorf("Expected user ID %s, got %s", userID, stored.UserID)
	}
}

func TestCreateReservationInvalidInput(t *testing.T) {
	repo := NewMockReservationRepository()
	svc := service.NewReservationService(repo)

	tests := []struct {
		name        string
		userID      uuid.UUID
		apartmentID uuid.UUID
	}{
		{
			name:        "empty user_id",
			userID:      uuid.Nil,
			apartmentID: uuid.New(),
		},
		{
			name:        "empty apartment_id",
			userID:      uuid.New(),
			apartmentID: uuid.Nil,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := svc.CreateReservation(context.Background(), tt.userID, tt.apartmentID, nil)
			if err == nil {
				t.Error("Expected validation error")
			}

			if pkgerrors.GetErrorCode(err) != pkgerrors.CodeInvalidArgument {
				t.Errorf("Expected InvalidArgument error, got %s", pkgerrors.GetErrorCode(err))
			}
		})
	}
}

func TestConfirmReservationSuccess(t *testing.T) {
	repo := NewMockReservationRepository()
	eventPublisher := NewMockEventPublisher()
	svc := service.NewReservationService(repo)
	createUseCase := usecase.NewCreateReservationUseCase(svc, eventPublisher)
	confirmUseCase := usecase.NewConfirmReservationUseCase(svc, eventPublisher)

	userID := uuid.New()
	apartmentID := uuid.New()
	createInput := dto.CreateReservationInput{
		UserID:      userID,
		ApartmentID: apartmentID,
	}
	createOutput, _ := createUseCase.Execute(context.Background(), createInput)

	confirmInput := dto.ConfirmReservationInput{
		ReservationID: createOutput.ReservationID,
	}
	confirmOutput, err := confirmUseCase.Execute(context.Background(), confirmInput)
	if err != nil {
		t.Fatalf("Failed to confirm reservation: %v", err)
	}

	if !confirmOutput.Success {
		t.Error("Expected success to be true")
	}

	if len(eventPublisher.ConfirmedEvents) != 1 {
		t.Errorf("Expected 1 confirmed event, got %d", len(eventPublisher.ConfirmedEvents))
	}

	stored, _ := repo.GetByID(context.Background(), createOutput.ReservationID)
	if stored.Status != entity.StatusConfirmed {
		t.Errorf("Expected status CONFIRMED, got %s", stored.Status)
	}
}

func TestConfirmReservationNotFound(t *testing.T) {
	repo := NewMockReservationRepository()
	svc := service.NewReservationService(repo)

	_, err := svc.ConfirmReservation(context.Background(), uuid.New())
	if err == nil {
		t.Error("Expected not found error")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeNotFound {
		t.Errorf("Expected NotFound error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestConfirmReservationInvalidState(t *testing.T) {
	repo := NewMockReservationRepository()
	svc := service.NewReservationService(repo)

	reservation, _ := svc.CreateReservation(context.Background(), uuid.New(), uuid.New(), nil)
	svc.CancelReservation(context.Background(), reservation.ID)

	_, err := svc.ConfirmReservation(context.Background(), reservation.ID)
	if err == nil {
		t.Error("Expected failed precondition error")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeFailedPrecondition {
		t.Errorf("Expected FailedPrecondition error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestCancelReservationSuccess(t *testing.T) {
	repo := NewMockReservationRepository()
	eventPublisher := NewMockEventPublisher()
	svc := service.NewReservationService(repo)
	createUseCase := usecase.NewCreateReservationUseCase(svc, eventPublisher)
	cancelUseCase := usecase.NewCancelReservationUseCase(svc, eventPublisher)

	createInput := dto.CreateReservationInput{
		UserID:      uuid.New(),
		ApartmentID: uuid.New(),
	}
	createOutput, _ := createUseCase.Execute(context.Background(), createInput)

	cancelInput := dto.CancelReservationInput{
		ReservationID: createOutput.ReservationID,
	}
	cancelOutput, err := cancelUseCase.Execute(context.Background(), cancelInput)
	if err != nil {
		t.Fatalf("Failed to cancel reservation: %v", err)
	}

	if !cancelOutput.Success {
		t.Error("Expected success to be true")
	}

	if len(eventPublisher.CancelledEvents) != 1 {
		t.Errorf("Expected 1 cancelled event, got %d", len(eventPublisher.CancelledEvents))
	}

	stored, _ := repo.GetByID(context.Background(), createOutput.ReservationID)
	if stored.Status != entity.StatusCancelled {
		t.Errorf("Expected status CANCELLED, got %s", stored.Status)
	}
}

func TestGetReservationSuccess(t *testing.T) {
	repo := NewMockReservationRepository()
	eventPublisher := NewMockEventPublisher()
	svc := service.NewReservationService(repo)
	createUseCase := usecase.NewCreateReservationUseCase(svc, eventPublisher)
	getUseCase := usecase.NewGetReservationUseCase(svc)

	userID := uuid.New()
	apartmentID := uuid.New()
	createInput := dto.CreateReservationInput{
		UserID:      userID,
		ApartmentID: apartmentID,
	}
	createOutput, _ := createUseCase.Execute(context.Background(), createInput)

	getInput := dto.GetReservationInput{
		ReservationID: createOutput.ReservationID,
	}
	getOutput, err := getUseCase.Execute(context.Background(), getInput)
	if err != nil {
		t.Fatalf("Failed to get reservation: %v", err)
	}

	if getOutput.ID != createOutput.ReservationID {
		t.Errorf("Expected ID %s, got %s", createOutput.ReservationID, getOutput.ID)
	}
	if getOutput.UserID != userID {
		t.Errorf("Expected user ID %s, got %s", userID, getOutput.UserID)
	}
	if getOutput.Status != string(entity.StatusPending) {
		t.Errorf("Expected status PENDING, got %s", getOutput.Status)
	}
}

func TestGetReservationNotFound(t *testing.T) {
	repo := NewMockReservationRepository()
	svc := service.NewReservationService(repo)

	_, err := svc.GetReservation(context.Background(), uuid.New())
	if err == nil {
		t.Error("Expected not found error")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeNotFound {
		t.Errorf("Expected NotFound error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestListReservationsByUserSuccess(t *testing.T) {
	repo := NewMockReservationRepository()
	eventPublisher := NewMockEventPublisher()
	svc := service.NewReservationService(repo)
	createUseCase := usecase.NewCreateReservationUseCase(svc, eventPublisher)
	listUseCase := usecase.NewListReservationsByUserUseCase(svc)

	userID := uuid.New()

	for i := 0; i < 3; i++ {
		createInput := dto.CreateReservationInput{
			UserID:      userID,
			ApartmentID: uuid.New(),
		}
		createUseCase.Execute(context.Background(), createInput)
	}

	listInput := dto.ListReservationsByUserInput{
		UserID: userID,
	}
	listOutput, err := listUseCase.Execute(context.Background(), listInput)
	if err != nil {
		t.Fatalf("Failed to list reservations: %v", err)
	}

	if len(listOutput.Items) != 3 {
		t.Errorf("Expected 3 reservations, got %d", len(listOutput.Items))
	}

	for _, item := range listOutput.Items {
		if item.UserID != userID {
			t.Errorf("Expected user ID %s, got %s", userID, item.UserID)
		}
	}
}

func TestListReservationsByUserEmpty(t *testing.T) {
	repo := NewMockReservationRepository()
	svc := service.NewReservationService(repo)
	listUseCase := usecase.NewListReservationsByUserUseCase(svc)

	listInput := dto.ListReservationsByUserInput{
		UserID: uuid.New(),
	}
	listOutput, err := listUseCase.Execute(context.Background(), listInput)
	if err != nil {
		t.Fatalf("Failed to list reservations: %v", err)
	}

	if len(listOutput.Items) != 0 {
		t.Errorf("Expected 0 reservations, got %d", len(listOutput.Items))
	}
}

func TestReservationIsExpired(t *testing.T) {
	r1 := &entity.Reservation{
		ID:         uuid.New(),
		UserID:     uuid.New(),
		ApartmentID: uuid.New(),
		Status:     entity.StatusPending,
		ExpiresAt:  nil,
	}
	if r1.IsExpired() {
		t.Error("Reservation with no expiry should not be expired")
	}

	futureTime := time.Now().Add(1 * time.Hour)
	r2 := &entity.Reservation{
		ID:         uuid.New(),
		UserID:     uuid.New(),
		ApartmentID: uuid.New(),
		Status:     entity.StatusPending,
		ExpiresAt:  &futureTime,
	}
	if r2.IsExpired() {
		t.Error("Reservation with future expiry should not be expired")
	}

	pastTime := time.Now().Add(-1 * time.Hour)
	r3 := &entity.Reservation{
		ID:         uuid.New(),
		UserID:     uuid.New(),
		ApartmentID: uuid.New(),
		Status:     entity.StatusPending,
		ExpiresAt:  &pastTime,
	}
	if !r3.IsExpired() {
		t.Error("Reservation with past expiry should be expired")
	}
}

