package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
)

type GetReservationUseCase struct {
	reservationService *service.ReservationService
}

func NewGetReservationUseCase(reservationService *service.ReservationService) *GetReservationUseCase {
	return &GetReservationUseCase{
		reservationService: reservationService,
	}
}

func (uc *GetReservationUseCase) Execute(ctx context.Context, input dto.GetReservationInput) (*dto.GetReservationOutput, error) {
	reservation, err := uc.reservationService.GetReservation(ctx, input.ReservationID)
	if err != nil {
		return nil, fmt.Errorf("failed to get reservation: %w", err)
	}

	output := dto.ToGetReservationOutput(reservation)
	return &output, nil
}

