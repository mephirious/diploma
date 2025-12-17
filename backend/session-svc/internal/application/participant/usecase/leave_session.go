package usecase

import (
	"context"

	participantDto "github.com/diploma/session-svc/internal/application/participant/dto"
	sessionUsecase "github.com/diploma/session-svc/internal/application/session/usecase"
	participantService "github.com/diploma/session-svc/internal/domain/participant/service"
	sessionService "github.com/diploma/session-svc/internal/domain/session/service"
)

type LeaveSessionUseCase struct {
	sessionService     *sessionService.SessionService
	participantService *participantService.ParticipantService
	eventPublisher     sessionUsecase.EventPublisher
}

func NewLeaveSessionUseCase(
	sessionService *sessionService.SessionService,
	participantService *participantService.ParticipantService,
	eventPublisher sessionUsecase.EventPublisher,
) *LeaveSessionUseCase {
	return &LeaveSessionUseCase{
		sessionService:     sessionService,
		participantService: participantService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *LeaveSessionUseCase) Execute(ctx context.Context, input participantDto.LeaveSessionInput) (*participantDto.LeaveSessionOutput, error) {
	err := uc.participantService.RemoveParticipant(ctx, input.SessionID, input.UserID)
	if err != nil {
		return nil, err
	}

	if err := uc.sessionService.UpdateSessionParticipantCount(ctx, input.SessionID); err != nil {
		return nil, err
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishSessionLeft(ctx, input.SessionID, input.UserID)
	}

	return &participantDto.LeaveSessionOutput{
		Success: true,
	}, nil
}

