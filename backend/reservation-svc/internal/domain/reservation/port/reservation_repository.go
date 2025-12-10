package port

import (
	"context"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/google/uuid"
)

type ReservationRepository interface {
	Create(ctx context.Context, reservation *entity.Reservation) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Reservation, error)
	Update(ctx context.Context, reservation *entity.Reservation) error
	ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error)
}

