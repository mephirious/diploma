package usecase

import (
	"context"

	"github.com/diploma/session-svc/internal/application/session/dto"
	"github.com/diploma/session-svc/internal/domain/session/service"
)

type GetSessionUseCase struct {
	sessionService *service.SessionService
}

func NewGetSessionUseCase(sessionService *service.SessionService) *GetSessionUseCase {
	return &GetSessionUseCase{
		sessionService: sessionService,
	}
}

func (uc *GetSessionUseCase) Execute(ctx context.Context, input dto.GetSessionInput) (*dto.GetSessionOutput, error) {
	session, err := uc.sessionService.GetSession(ctx, input.SessionID)
	if err != nil {
		return nil, err
	}

	output := dto.ToSessionOutput(session)
	return &output, nil
}

