package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/resource/dto"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
)

type UpdateResourceUseCase struct {
	resourceService *service.ResourceService
}

func NewUpdateResourceUseCase(resourceService *service.ResourceService) *UpdateResourceUseCase {
	return &UpdateResourceUseCase{
		resourceService: resourceService,
	}
}

func (uc *UpdateResourceUseCase) Execute(ctx context.Context, input dto.UpdateResourceInput) (*dto.UpdateResourceOutput, error) {
	_, err := uc.resourceService.UpdateResource(
		ctx,
		input.ResourceID,
		input.Name,
		input.SportType,
		input.SurfaceType,
		input.Capacity,
		input.IsActive,
	)
	if err != nil {
		return nil, err
	}

	return &dto.UpdateResourceOutput{
		Success: true,
	}, nil
}

