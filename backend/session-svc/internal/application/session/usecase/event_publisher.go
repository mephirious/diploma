package usecase

import (
	"context"

	"github.com/google/uuid"
)

type EventPublisher interface {
	PublishSessionCreated(ctx context.Context, sessionID, reservationID, hostID uuid.UUID) error
	PublishSessionJoined(ctx context.Context, sessionID, userID uuid.UUID, currentParticipants int) error
	PublishSessionFull(ctx context.Context, sessionID uuid.UUID) error
	PublishSessionCancelled(ctx context.Context, sessionID uuid.UUID) error
	PublishSessionLeft(ctx context.Context, sessionID, userID uuid.UUID) error
}

