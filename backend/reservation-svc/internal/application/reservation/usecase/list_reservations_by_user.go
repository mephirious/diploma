package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
)

type ListReservationsByUserUseCase struct {
	reservationService *service.ReservationService
}

func NewListReservationsByUserUseCase(reservationService *service.ReservationService) *ListReservationsByUserUseCase {
	return &ListReservationsByUserUseCase{
		reservationService: reservationService,
	}
}

func (uc *ListReservationsByUserUseCase) Execute(ctx context.Context, input dto.ListReservationsByUserInput) (*dto.ListReservationsByUserOutput, error) {
	reservations, err := uc.reservationService.ListReservationsByUser(ctx, input.UserID)
	if err != nil {
		return nil, fmt.Errorf("failed to list reservations: %w", err)
	}

	items := make([]dto.GetReservationOutput, 0, len(reservations))
	for _, reservation := range reservations {
		items = append(items, dto.ToGetReservationOutput(reservation))
	}

	return &dto.ListReservationsByUserOutput{
		Items: items,
	}, nil
}

