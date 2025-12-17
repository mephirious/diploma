package service

import (
	"context"
	"fmt"

	participantPort "github.com/diploma/session-svc/internal/domain/participant/port"
	"github.com/diploma/session-svc/internal/domain/session/entity"
	"github.com/diploma/session-svc/internal/domain/session/port"
	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
)

type SessionService struct {
	sessionRepo     port.SessionRepository
	participantRepo participantPort.ParticipantRepository
}

func NewSessionService(sessionRepo port.SessionRepository, participantRepo participantPort.ParticipantRepository) *SessionService {
	return &SessionService{
		sessionRepo:     sessionRepo,
		participantRepo: participantRepo,
	}
}

func (s *SessionService) CreateSession(
	ctx context.Context,
	reservationID, hostID uuid.UUID,
	sportType, skillLevel string,
	maxParticipants, minParticipants int,
	pricePerParticipant float64,
	visibility entity.SessionVisibility,
	description string,
) (*entity.Session, error) {
	existing, err := s.sessionRepo.GetByReservationID(ctx, reservationID)
	if err == nil && existing != nil {
		return nil, pkgerrors.NewAlreadyExistsError("session already exists for this reservation")
	}

	session := &entity.Session{
		ID:                  uuid.New(),
		ReservationID:       reservationID,
		HostID:              hostID,
		SportType:           sportType,
		SkillLevel:          skillLevel,
		MaxParticipants:     maxParticipants,
		MinParticipants:     minParticipants,
		CurrentParticipants: 1, // Host is automatically included
		PricePerParticipant: pricePerParticipant,
		Visibility:          visibility,
		Status:              entity.SessionStatusOpen,
		Description:         description,
	}

	if err := session.IsValid(); err != nil {
		return nil, err
	}

	if err := s.sessionRepo.Create(ctx, session); err != nil {
		return nil, fmt.Errorf("failed to create session: %w", err)
	}

	return session, nil
}

func (s *SessionService) GetSession(ctx context.Context, id uuid.UUID) (*entity.Session, error) {
	if id == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	return s.sessionRepo.GetByID(ctx, id)
}

func (s *SessionService) ListOpenSessions(ctx context.Context, sportType, skillLevel string, page, pageSize int) ([]*entity.Session, int, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	offset := (page - 1) * pageSize
	return s.sessionRepo.ListOpen(ctx, sportType, skillLevel, offset, pageSize)
}

func (s *SessionService) ListUserSessions(ctx context.Context, userID uuid.UUID, page, pageSize int) ([]*entity.Session, int, error) {
	if userID == uuid.Nil {
		return nil, 0, pkgerrors.NewInvalidArgumentError("user_id is required")
	}

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	offset := (page - 1) * pageSize
	return s.sessionRepo.ListByUserID(ctx, userID, offset, pageSize)
}

func (s *SessionService) CancelSession(ctx context.Context, sessionID, userID uuid.UUID) error {
	session, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return err
	}

	if !session.IsHost(userID) {
		return pkgerrors.NewPermissionDeniedError("only the host can cancel the session")
	}

	if err := session.Cancel(); err != nil {
		return err
	}

	if err := s.sessionRepo.Update(ctx, session); err != nil {
		return fmt.Errorf("failed to cancel session: %w", err)
	}

	return nil
}

func (s *SessionService) UpdateSessionParticipantCount(ctx context.Context, sessionID uuid.UUID) error {
	session, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return err
	}

	count, err := s.participantRepo.CountActiveBySessionID(ctx, sessionID)
	if err != nil {
		return fmt.Errorf("failed to count participants: %w", err)
	}

	session.CurrentParticipants = count

	if count >= session.MaxParticipants && session.Status == entity.SessionStatusOpen {
		session.Status = entity.SessionStatusFull
	} else if count < session.MaxParticipants && session.Status == entity.SessionStatusFull {
		session.Status = entity.SessionStatusOpen
	}

	return s.sessionRepo.Update(ctx, session)
}

