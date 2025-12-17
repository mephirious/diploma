package service

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/port"
	pkgerrors "github.com/diploma/reservation-svc/pkg/errors"
	"github.com/google/uuid"
)

type ReservationService struct {
	repo port.ReservationRepository
}

func NewReservationService(repo port.ReservationRepository) *ReservationService {
	return &ReservationService{
		repo: repo,
	}
}

func (s *ReservationService) CreateReservation(ctx context.Context, userID, apartmentID uuid.UUID, comment *string) (*entity.Reservation, error) {
	if userID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("user_id is required")
	}
	if apartmentID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("apartment_id is required")
	}

	reservation := &entity.Reservation{
		ID:          uuid.New(),
		UserID:      userID,
		ApartmentID: apartmentID,
		Status:      entity.StatusPending,
		Comment:     comment,
	}

	if !reservation.IsValid() {
		return nil, pkgerrors.NewInvalidArgumentError("invalid reservation data")
	}

	if err := s.repo.Create(ctx, reservation); err != nil {
		return nil, fmt.Errorf("failed to create reservation: %w", err)
	}

	return reservation, nil
}

func (s *ReservationService) ConfirmReservation(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	reservation, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err // Repository already returns typed error
	}

	if err := reservation.Confirm(); err != nil {
		return nil, err // Entity already returns typed error
	}

	if err := s.repo.Update(ctx, reservation); err != nil {
		return nil, fmt.Errorf("failed to update reservation: %w", err)
	}

	return reservation, nil
}

func (s *ReservationService) CancelReservation(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	reservation, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err // Repository already returns typed error
	}

	if err := reservation.Cancel(); err != nil {
		return nil, err // Entity already returns typed error
	}

	if err := s.repo.Update(ctx, reservation); err != nil {
		return nil, fmt.Errorf("failed to update reservation: %w", err)
	}

	return reservation, nil
}

func (s *ReservationService) GetReservation(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	if id == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("reservation_id is required")
	}
	return s.repo.GetByID(ctx, id)
}

func (s *ReservationService) ListReservationsByUser(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	if userID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("user_id is required")
	}
	return s.repo.ListByUserID(ctx, userID)
}

