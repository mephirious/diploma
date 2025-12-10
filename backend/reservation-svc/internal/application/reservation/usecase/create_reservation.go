package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
)

type CreateReservationUseCase struct {
	reservationService *service.ReservationService
	eventPublisher     EventPublisher
}

func NewCreateReservationUseCase(
	reservationService *service.ReservationService,
	eventPublisher EventPublisher,
) *CreateReservationUseCase {
	return &CreateReservationUseCase{
		reservationService: reservationService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *CreateReservationUseCase) Execute(ctx context.Context, input dto.CreateReservationInput) (*dto.CreateReservationOutput, error) {
	reservation, err := uc.reservationService.CreateReservation(ctx, input.UserID, input.ApartmentID, input.Comment)
	if err != nil {
		return nil, fmt.Errorf("failed to create reservation: %w", err)
	}

	if err := uc.eventPublisher.PublishReservationCreated(ctx, reservation.ID.String(), reservation.UserID.String(), reservation.ApartmentID.String()); err != nil {
		fmt.Printf("Warning: Failed to publish RESERVATION.CREATED event: %v\n", err)
	}

	return &dto.CreateReservationOutput{
		ReservationID: reservation.ID,
	}, nil
}

