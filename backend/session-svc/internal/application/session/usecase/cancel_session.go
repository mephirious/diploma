package usecase

import (
	"context"

	"github.com/diploma/session-svc/internal/application/session/dto"
	"github.com/diploma/session-svc/internal/domain/session/service"
)

type CancelSessionUseCase struct {
	sessionService *service.SessionService
	eventPublisher EventPublisher
}

func NewCancelSessionUseCase(sessionService *service.SessionService, eventPublisher EventPublisher) *CancelSessionUseCase {
	return &CancelSessionUseCase{
		sessionService: sessionService,
		eventPublisher: eventPublisher,
	}
}

func (uc *CancelSessionUseCase) Execute(ctx context.Context, input dto.CancelSessionInput) (*dto.CancelSessionOutput, error) {
	err := uc.sessionService.CancelSession(ctx, input.SessionID, input.UserID)
	if err != nil {
		return nil, err
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishSessionCancelled(ctx, input.SessionID)
	}

	return &dto.CancelSessionOutput{
		Success: true,
	}, nil
}

