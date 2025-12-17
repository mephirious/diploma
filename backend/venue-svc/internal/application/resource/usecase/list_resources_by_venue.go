package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/resource/dto"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
)

type ListResourcesByVenueUseCase struct {
	resourceService *service.ResourceService
}

func NewListResourcesByVenueUseCase(resourceService *service.ResourceService) *ListResourcesByVenueUseCase {
	return &ListResourcesByVenueUseCase{
		resourceService: resourceService,
	}
}

func (uc *ListResourcesByVenueUseCase) Execute(ctx context.Context, input dto.ListResourcesByVenueInput) (*dto.ListResourcesByVenueOutput, error) {
	resources, err := uc.resourceService.ListResourcesByVenue(ctx, input.VenueID, input.ActiveOnly)
	if err != nil {
		return nil, err
	}

	items := make([]dto.GetResourceOutput, len(resources))
	for i, resource := range resources {
		items[i] = dto.ToResourceOutput(resource)
	}

	return &dto.ListResourcesByVenueOutput{
		Items: items,
	}, nil
}

