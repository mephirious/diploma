package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/venue/dto"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
)

type ListVenuesUseCase struct {
	venueService *service.VenueService
}

func NewListVenuesUseCase(venueService *service.VenueService) *ListVenuesUseCase {
	return &ListVenuesUseCase{
		venueService: venueService,
	}
}

func (uc *ListVenuesUseCase) Execute(ctx context.Context, input dto.ListVenuesInput) (*dto.ListVenuesOutput, error) {
	venues, totalCount, err := uc.venueService.ListVenues(ctx, input.City, input.Page, input.PageSize)
	if err != nil {
		return nil, err
	}

	items := make([]dto.GetVenueOutput, len(venues))
	for i, venue := range venues {
		items[i] = dto.ToVenueOutput(venue)
	}

	return &dto.ListVenuesOutput{
		Items:      items,
		TotalCount: totalCount,
	}, nil
}

