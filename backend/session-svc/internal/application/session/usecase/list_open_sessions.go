package usecase

import (
	"context"

	"github.com/diploma/session-svc/internal/application/session/dto"
	"github.com/diploma/session-svc/internal/domain/session/service"
)

type ListOpenSessionsUseCase struct {
	sessionService *service.SessionService
}

func NewListOpenSessionsUseCase(sessionService *service.SessionService) *ListOpenSessionsUseCase {
	return &ListOpenSessionsUseCase{
		sessionService: sessionService,
	}
}

func (uc *ListOpenSessionsUseCase) Execute(ctx context.Context, input dto.ListOpenSessionsInput) (*dto.ListOpenSessionsOutput, error) {
	sessions, totalCount, err := uc.sessionService.ListOpenSessions(
		ctx,
		input.SportType,
		input.SkillLevel,
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

	return &dto.ListOpenSessionsOutput{
		Items:      items,
		TotalCount: totalCount,
	}, nil
}

