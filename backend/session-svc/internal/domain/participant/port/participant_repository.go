package port

import (
	"context"

	"github.com/diploma/session-svc/internal/domain/participant/entity"
	"github.com/google/uuid"
)

type ParticipantRepository interface {
	Create(ctx context.Context, participant *entity.Participant) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Participant, error)
	GetBySessionAndUser(ctx context.Context, sessionID, userID uuid.UUID) (*entity.Participant, error)
	ListBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error)
	ListActiveBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error)
	CountActiveBySessionID(ctx context.Context, sessionID uuid.UUID) (int, error)
	Update(ctx context.Context, participant *entity.Participant) error
	Delete(ctx context.Context, id uuid.UUID) error
}

