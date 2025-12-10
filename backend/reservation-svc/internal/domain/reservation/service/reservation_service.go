package service

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/port"
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
		return nil, errors.New("user_id is required")
	}
	if apartmentID == uuid.Nil {
		return nil, errors.New("apartment_id is required")
	}

	reservation := &entity.Reservation{
		ID:          uuid.New(),
		UserID:      userID,
		ApartmentID: apartmentID,
		Status:      entity.StatusPending,
		Comment:     comment,
	}

	if err := s.repo.Create(ctx, reservation); err != nil {
		return nil, fmt.Errorf("failed to create reservation: %w", err)
	}

	return reservation, nil
}

func (s *ReservationService) ConfirmReservation(ctx context.Context, id uuid.UUID) error {
	reservation, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("reservation not found: %w", err)
	}

	if err := reservation.Confirm(); err != nil {
		return err
	}

	if err := s.repo.Update(ctx, reservation); err != nil {
		return fmt.Errorf("failed to update reservation: %w", err)
	}

	return nil
}

func (s *ReservationService) CancelReservation(ctx context.Context, id uuid.UUID) error {
	reservation, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("reservation not found: %w", err)
	}

	if err := reservation.Cancel(); err != nil {
		return err
	}

	if err := s.repo.Update(ctx, reservation); err != nil {
		return fmt.Errorf("failed to update reservation: %w", err)
	}

	return nil
}

func (s *ReservationService) GetReservation(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *ReservationService) ListReservationsByUser(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	if userID == uuid.Nil {
		return nil, errors.New("user_id is required")
	}
	return s.repo.ListByUserID(ctx, userID)
}

