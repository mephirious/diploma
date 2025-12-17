package usecase

import (
	"context"

	"github.com/diploma/session-svc/internal/application/session/dto"
	"github.com/diploma/session-svc/internal/domain/session/service"
)

type ListUserSessionsUseCase struct {
	sessionService *service.SessionService
}

func NewListUserSessionsUseCase(sessionService *service.SessionService) *ListUserSessionsUseCase {
	return &ListUserSessionsUseCase{
		sessionService: sessionService,
	}
}

func (uc *ListUserSessionsUseCase) Execute(ctx context.Context, input dto.ListUserSessionsInput) (*dto.ListUserSessionsOutput, error) {
	sessions, totalCount, err := uc.sessionService.ListUserSessions(
		ctx,
		input.UserID,
		input.Page,
		input.PageSize,
	)
	if err != nil {
		return nil, err
	}

	items := make([]dto.GetSessionOutput, len(sessions))
	for i, session := range sessions {
		items[i] = dto.ToSessionOutput(session)
	}

	return &dto.ListUserSessionsOutput{
		Items:      items,
		TotalCount: totalCount,
	}, nil
}

