package dto

import (
	"time"

	participantEntity "github.com/diploma/session-svc/internal/domain/participant/entity"
	"github.com/google/uuid"
)

type JoinSessionInput struct {
	SessionID uuid.UUID
	UserID    uuid.UUID
}

type JoinSessionOutput struct {
	Success       bool
	ParticipantID uuid.UUID
}

type LeaveSessionInput struct {
	SessionID uuid.UUID
	UserID    uuid.UUID
}

type LeaveSessionOutput struct {
	Success bool
}

type ListSessionParticipantsInput struct {
	SessionID uuid.UUID
}

type ParticipantOutput struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	Role      participantEntity.ParticipantRole
	Status    participantEntity.ParticipantStatus
	JoinedAt  time.Time
}

type ListSessionParticipantsOutput struct {
	Participants []ParticipantOutput
}

func ToParticipantOutput(participant *participantEntity.Participant) ParticipantOutput {
	return ParticipantOutput{
		ID:       participant.ID,
		UserID:   participant.UserID,
		Role:     participant.Role,
		Status:   participant.Status,
		JoinedAt: participant.JoinedAt,
	}
}

