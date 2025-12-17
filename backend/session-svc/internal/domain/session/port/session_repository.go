package port

import (
	"context"

	"github.com/diploma/session-svc/internal/domain/session/entity"
	"github.com/google/uuid"
)

type SessionRepository interface {
	Create(ctx context.Context, session *entity.Session) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Session, error)
	GetByReservationID(ctx context.Context, reservationID uuid.UUID) (*entity.Session, error)
	ListOpen(ctx context.Context, sportType, skillLevel string, offset, limit int) ([]*entity.Session, int, error)
	ListByUserID(ctx context.Context, userID uuid.UUID, offset, limit int) ([]*entity.Session, int, error)
	Update(ctx context.Context, session *entity.Session) error
	Delete(ctx context.Context, id uuid.UUID) error
}

