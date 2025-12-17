package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/resource/dto"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
)

type DeleteResourceUseCase struct {
	resourceService *service.ResourceService
}

func NewDeleteResourceUseCase(resourceService *service.ResourceService) *DeleteResourceUseCase {
	return &DeleteResourceUseCase{
		resourceService: resourceService,
	}
}

func (uc *DeleteResourceUseCase) Execute(ctx context.Context, input dto.DeleteResourceInput) (*dto.DeleteResourceOutput, error) {
	err := uc.resourceService.DeleteResource(ctx, input.ResourceID)
	if err != nil {
		return nil, err
	}

	return &dto.DeleteResourceOutput{
		Success: true,
	}, nil
}

