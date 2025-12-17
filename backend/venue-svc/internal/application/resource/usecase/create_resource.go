package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/resource/dto"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
)

type CreateResourceUseCase struct {
	resourceService *service.ResourceService
}

func NewCreateResourceUseCase(resourceService *service.ResourceService) *CreateResourceUseCase {
	return &CreateResourceUseCase{
		resourceService: resourceService,
	}
}

func (uc *CreateResourceUseCase) Execute(ctx context.Context, input dto.CreateResourceInput) (*dto.CreateResourceOutput, error) {
	resource, err := uc.resourceService.CreateResource(
		ctx,
		input.VenueID,
		input.Name,
		input.SportType,
		input.SurfaceType,
		input.Capacity,
		input.IsActive,
	)
	if err != nil {
		return nil, err
	}

	return &dto.CreateResourceOutput{
		ResourceID: resource.ID,
	}, nil
}

