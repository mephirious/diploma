package entity

import (
	"time"

	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
)

type SessionStatus string

const (
	SessionStatusOpen       SessionStatus = "OPEN"
	SessionStatusFull       SessionStatus = "FULL"
	SessionStatusInProgress SessionStatus = "IN_PROGRESS"
	SessionStatusCompleted  SessionStatus = "COMPLETED"
	SessionStatusCancelled  SessionStatus = "CANCELLED"
)

type SessionVisibility string

const (
	SessionVisibilityPublic  SessionVisibility = "PUBLIC"
	SessionVisibilityPrivate SessionVisibility = "PRIVATE"
)

type Session struct {
	ID                   uuid.UUID
	ReservationID        uuid.UUID
	HostID               uuid.UUID
	SportType            string
	SkillLevel           string // beginner, intermediate, advanced
	MaxParticipants      int
	MinParticipants      int
	CurrentParticipants  int
	PricePerParticipant  float64
	Visibility           SessionVisibility
	Status               SessionStatus
	Description          string
	CreatedAt            time.Time
	UpdatedAt            time.Time
}

func (s *Session) IsValid() error {
	if s.ReservationID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("reservation_id is required")
	}
	if s.HostID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("host_id is required")
	}
	if s.SportType == "" {
		return pkgerrors.NewInvalidArgumentError("sport_type is required")
	}
	if s.MaxParticipants <= 0 {
		return pkgerrors.NewInvalidArgumentError("max_participants must be positive")
	}
	if s.MinParticipants <= 0 {
		return pkgerrors.NewInvalidArgumentError("min_participants must be positive")
	}
	if s.MinParticipants > s.MaxParticipants {
		return pkgerrors.NewInvalidArgumentError("min_participants cannot exceed max_participants")
	}
	if s.PricePerParticipant < 0 {
		return pkgerrors.NewInvalidArgumentError("price_per_participant must be non-negative")
	}
	return nil
}

func (s *Session) CanAddParticipant() error {
	if s.Status == SessionStatusCancelled {
		return pkgerrors.NewFailedPreconditionError("cannot join cancelled session")
	}
	if s.Status == SessionStatusCompleted {
		return pkgerrors.NewFailedPreconditionError("cannot join completed session")
	}
	if s.Status == SessionStatusInProgress {
		return pkgerrors.NewFailedPreconditionError("cannot join session in progress")
	}
	if s.Status == SessionStatusFull {
		return pkgerrors.NewResourceExhaustedError("session is full")
	}
	if s.CurrentParticipants >= s.MaxParticipants {
		return pkgerrors.NewResourceExhaustedError("session has reached max capacity")
	}
	return nil
}

func (s *Session) AddParticipant() error {
	if err := s.CanAddParticipant(); err != nil {
		return err
	}

	s.CurrentParticipants++
	s.UpdatedAt = time.Now()

	if s.CurrentParticipants >= s.MaxParticipants {
		s.Status = SessionStatusFull
	}

	return nil
}

func (s *Session) RemoveParticipant() error {
	if s.CurrentParticipants <= 0 {
		return pkgerrors.NewFailedPreconditionError("no participants to remove")
	}

	s.CurrentParticipants--
	s.UpdatedAt = time.Now()

	if s.Status == SessionStatusFull && s.CurrentParticipants < s.MaxParticipants {
		s.Status = SessionStatusOpen
	}

	return nil
}

func (s *Session) CanCancel() error {
	if s.Status == SessionStatusCancelled {
		return pkgerrors.NewFailedPreconditionError("session is already cancelled")
	}
	if s.Status == SessionStatusCompleted {
		return pkgerrors.NewFailedPreconditionError("cannot cancel completed session")
	}
	return nil
}

func (s *Session) Cancel() error {
	if err := s.CanCancel(); err != nil {
		return err
	}

	s.Status = SessionStatusCancelled
	s.UpdatedAt = time.Now()
	return nil
}

func (s *Session) CanStart() error {
	if s.Status != SessionStatusOpen && s.Status != SessionStatusFull {
		return pkgerrors.NewFailedPreconditionError("session must be open or full to start")
	}
	if s.CurrentParticipants < s.MinParticipants {
		return pkgerrors.NewFailedPreconditionError("not enough participants to start")
	}
	return nil
}

func (s *Session) Start() error {
	if err := s.CanStart(); err != nil {
		return err
	}

	s.Status = SessionStatusInProgress
	s.UpdatedAt = time.Now()
	return nil
}

func (s *Session) Complete() error {
	if s.Status != SessionStatusInProgress {
		return pkgerrors.NewFailedPreconditionError("only in-progress sessions can be completed")
	}

	s.Status = SessionStatusCompleted
	s.UpdatedAt = time.Now()
	return nil
}

func (s *Session) IsHost(userID uuid.UUID) bool {
	return s.HostID == userID
}

func (s *Session) IsFull() bool {
	return s.CurrentParticipants >= s.MaxParticipants
}

func (s *Session) IsOpen() bool {
	return s.Status == SessionStatusOpen || s.Status == SessionStatusFull
}

