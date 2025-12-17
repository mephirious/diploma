package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
)

type CancelReservationUseCase struct {
	reservationService *service.ReservationService
	eventPublisher     EventPublisher
}

func NewCancelReservationUseCase(
	reservationService *service.ReservationService,
	eventPublisher EventPublisher,
) *CancelReservationUseCase {
	return &CancelReservationUseCase{
		reservationService: reservationService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *CancelReservationUseCase) Execute(ctx context.Context, input dto.CancelReservationInput) (*dto.CancelReservationOutput, error) {
	reservation, err := uc.reservationService.CancelReservation(ctx, input.ReservationID)
	if err != nil {
		return nil, fmt.Errorf("failed to cancel reservation: %w", err)
	}

	if err := uc.eventPublisher.PublishReservationCancelled(ctx, reservation.ID.String()); err != nil {
		fmt.Printf("Warning: Failed to publish RESERVATION.CANCELLED event: %v\n", err)
	}

	return &dto.CancelReservationOutput{
		Success: true,
	}, nil
}

