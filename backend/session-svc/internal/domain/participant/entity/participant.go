package entity

import (
	"time"

	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
)

type ParticipantRole string

const (
	ParticipantRoleHost   ParticipantRole = "HOST"
	ParticipantRolePlayer ParticipantRole = "PLAYER"
)

type ParticipantStatus string

const (
	ParticipantStatusJoined  ParticipantStatus = "JOINED"
	ParticipantStatusLeft    ParticipantStatus = "LEFT"
	ParticipantStatusRemoved ParticipantStatus = "REMOVED"
)

type Participant struct {
	ID        uuid.UUID
	SessionID uuid.UUID
	UserID    uuid.UUID
	Role      ParticipantRole
	Status    ParticipantStatus
	JoinedAt  time.Time
	UpdatedAt time.Time
}

func (p *Participant) IsValid() error {
	if p.SessionID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("session_id is required")
	}
	if p.UserID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("user_id is required")
	}
	if p.Role != ParticipantRoleHost && p.Role != ParticipantRolePlayer {
		return pkgerrors.NewInvalidArgumentError("invalid participant role")
	}
	return nil
}

func (p *Participant) CanLeave() error {
	if p.Status == ParticipantStatusLeft {
		return pkgerrors.NewFailedPreconditionError("participant has already left")
	}
	if p.Status == ParticipantStatusRemoved {
		return pkgerrors.NewFailedPreconditionError("participant was removed")
	}
	return nil
}

func (p *Participant) Leave() error {
	if err := p.CanLeave(); err != nil {
		return err
	}

	p.Status = ParticipantStatusLeft
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Participant) Remove() error {
	if p.Status == ParticipantStatusLeft {
		return pkgerrors.NewFailedPreconditionError("participant has already left")
	}
	if p.Status == ParticipantStatusRemoved {
		return pkgerrors.NewFailedPreconditionError("participant is already removed")
	}

	p.Status = ParticipantStatusRemoved
	p.UpdatedAt = time.Now()
	return nil
}

func (p *Participant) IsActive() bool {
	return p.Status == ParticipantStatusJoined
}

func (p *Participant) IsHost() bool {
	return p.Role == ParticipantRoleHost
}

