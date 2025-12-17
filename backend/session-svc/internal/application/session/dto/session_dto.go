package dto

import (
	"time"

	sessionEntity "github.com/diploma/session-svc/internal/domain/session/entity"
	"github.com/google/uuid"
)

type CreateSessionInput struct {
	ReservationID       uuid.UUID
	HostID              uuid.UUID
	SportType           string
	SkillLevel          string
	MaxParticipants     int
	MinParticipants     int
	PricePerParticipant float64
	Visibility          sessionEntity.SessionVisibility
	Description         string
}

type CreateSessionOutput struct{
	SessionID uuid.UUID
}

type GetSessionInput struct {
	SessionID uuid.UUID
}

type GetSessionOutput struct {
	ID                  uuid.UUID
	ReservationID       uuid.UUID
	HostID              uuid.UUID
	SportType           string
	SkillLevel          string
	MaxParticipants     int
	MinParticipants     int
	CurrentParticipants int
	PricePerParticipant float64
	Visibility          sessionEntity.SessionVisibility
	Status              sessionEntity.SessionStatus
	Description         string
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

type ListOpenSessionsInput struct {
	SportType  string
	SkillLevel string
	Page       int
	PageSize   int
}

type ListOpenSessionsOutput struct {
	Items      []GetSessionOutput
	TotalCount int
}

type ListUserSessionsInput struct {
	UserID   uuid.UUID
	Page     int
	PageSize int
}

type ListUserSessionsOutput struct {
	Items      []GetSessionOutput
	TotalCount int
}

type CancelSessionInput struct {
	SessionID uuid.UUID
	UserID    uuid.UUID
}

type CancelSessionOutput struct {
	Success bool
}

func ToSessionOutput(session *sessionEntity.Session) GetSessionOutput {
	return GetSessionOutput{
		ID:                  session.ID,
		ReservationID:       session.ReservationID,
		HostID:              session.HostID,
		SportType:           session.SportType,
		SkillLevel:          session.SkillLevel,
		MaxParticipants:     session.MaxParticipants,
		MinParticipants:     session.MinParticipants,
		CurrentParticipants: session.CurrentParticipants,
		PricePerParticipant: session.PricePerParticipant,
		Visibility:          session.Visibility,
		Status:              session.Status,
		Description:         session.Description,
		CreatedAt:           session.CreatedAt,
		UpdatedAt:           session.UpdatedAt,
	}
}

