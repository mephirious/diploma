package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/resource/dto"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
)

type GetResourceUseCase struct {
	resourceService *service.ResourceService
}

func NewGetResourceUseCase(resourceService *service.ResourceService) *GetResourceUseCase {
	return &GetResourceUseCase{
		resourceService: resourceService,
	}
}

func (uc *GetResourceUseCase) Execute(ctx context.Context, input dto.GetResourceInput) (*dto.GetResourceOutput, error) {
	resource, err := uc.resourceService.GetResource(ctx, input.ResourceID)
	if err != nil {
		return nil, err
	}

	output := dto.ToResourceOutput(resource)
	return &output, nil
}

