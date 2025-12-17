package service

import (
	"context"
	"fmt"

	"github.com/diploma/session-svc/internal/domain/participant/entity"
	"github.com/diploma/session-svc/internal/domain/participant/port"
	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
)

type ParticipantService struct {
	repo port.ParticipantRepository
}

func NewParticipantService(repo port.ParticipantRepository) *ParticipantService {
	return &ParticipantService{
		repo: repo,
	}
}

func (s *ParticipantService) AddParticipant(ctx context.Context, sessionID, userID uuid.UUID, role entity.ParticipantRole) (*entity.Participant, error) {
	existing, err := s.repo.GetBySessionAndUser(ctx, sessionID, userID)
	if err == nil && existing != nil {
		if existing.IsActive() {
			return nil, pkgerrors.NewAlreadyExistsError("user is already a participant in this session")
		}
	}

	participant := &entity.Participant{
		ID:        uuid.New(),
		SessionID: sessionID,
		UserID:    userID,
		Role:      role,
		Status:    entity.ParticipantStatusJoined,
	}

	if err := participant.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Create(ctx, participant); err != nil {
		return nil, fmt.Errorf("failed to add participant: %w", err)
	}

	return participant, nil
}

func (s *ParticipantService) RemoveParticipant(ctx context.Context, sessionID, userID uuid.UUID) error {
	participant, err := s.repo.GetBySessionAndUser(ctx, sessionID, userID)
	if err != nil {
		return err
	}

	if err := participant.Leave(); err != nil {
		return err
	}

	if err := s.repo.Update(ctx, participant); err != nil {
		return fmt.Errorf("failed to remove participant: %w", err)
	}

	return nil
}

func (s *ParticipantService) ListSessionParticipants(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	if sessionID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	return s.repo.ListBySessionID(ctx, sessionID)
}

func (s *ParticipantService) ListActiveParticipants(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	if sessionID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	return s.repo.ListActiveBySessionID(ctx, sessionID)
}

func (s *ParticipantService) CountActiveParticipants(ctx context.Context, sessionID uuid.UUID) (int, error) {
	if sessionID == uuid.Nil {
		return 0, pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	return s.repo.CountActiveBySessionID(ctx, sessionID)
}

