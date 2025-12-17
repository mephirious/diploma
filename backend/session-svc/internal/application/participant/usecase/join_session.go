package usecase

import (
	"context"

	participantDto "github.com/diploma/session-svc/internal/application/participant/dto"
	sessionUsecase "github.com/diploma/session-svc/internal/application/session/usecase"
	participantEntity "github.com/diploma/session-svc/internal/domain/participant/entity"
	participantService "github.com/diploma/session-svc/internal/domain/participant/service"
	sessionService "github.com/diploma/session-svc/internal/domain/session/service"
)

type JoinSessionUseCase struct {
	sessionService     *sessionService.SessionService
	participantService *participantService.ParticipantService
	eventPublisher     sessionUsecase.EventPublisher
}

func NewJoinSessionUseCase(
	sessionService *sessionService.SessionService,
	participantService *participantService.ParticipantService,
	eventPublisher sessionUsecase.EventPublisher,
) *JoinSessionUseCase {
	return &JoinSessionUseCase{
		sessionService:     sessionService,
		participantService: participantService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *JoinSessionUseCase) Execute(ctx context.Context, input participantDto.JoinSessionInput) (*participantDto.JoinSessionOutput, error) {
	session, err := uc.sessionService.GetSession(ctx, input.SessionID)
	if err != nil {
		return nil, err
	}

	if err := session.CanAddParticipant(); err != nil {
		return nil, err
	}

	participant, err := uc.participantService.AddParticipant(
		ctx,
		input.SessionID,
		input.UserID,
		participantEntity.ParticipantRolePlayer,
	)
	if err != nil {
		return nil, err
	}

	if err := uc.sessionService.UpdateSessionParticipantCount(ctx, input.SessionID); err != nil {
		return nil, err
	}

	session, err = uc.sessionService.GetSession(ctx, input.SessionID)
	if err != nil {
		return nil, err
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishSessionJoined(ctx, input.SessionID, input.UserID, session.CurrentParticipants)
		
		if session.IsFull() {
			_ = uc.eventPublisher.PublishSessionFull(ctx, input.SessionID)
		}
	}

	return &participantDto.JoinSessionOutput{
		Success:       true,
		ParticipantID: participant.ID,
	}, nil
}

