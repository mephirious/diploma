package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
)

type ConfirmReservationUseCase struct {
	reservationService *service.ReservationService
	eventPublisher     EventPublisher
}

func NewConfirmReservationUseCase(
	reservationService *service.ReservationService,
	eventPublisher EventPublisher,
) *ConfirmReservationUseCase {
	return &ConfirmReservationUseCase{
		reservationService: reservationService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *ConfirmReservationUseCase) Execute(ctx context.Context, input dto.ConfirmReservationInput) (*dto.ConfirmReservationOutput, error) {
	if err := uc.reservationService.ConfirmReservation(ctx, input.ReservationID); err != nil {
		return nil, fmt.Errorf("failed to confirm reservation: %w", err)
	}

	if err := uc.eventPublisher.PublishReservationConfirmed(ctx, input.ReservationID.String()); err != nil {
		fmt.Printf("Warning: Failed to publish RESERVATION.CONFIRMED event: %v\n", err)
	}

	return &dto.ConfirmReservationOutput{
		Success: true,
	}, nil
}

