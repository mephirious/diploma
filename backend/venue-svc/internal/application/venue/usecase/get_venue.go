package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/venue/dto"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
)

type GetVenueUseCase struct {
	venueService *service.VenueService
}

func NewGetVenueUseCase(venueService *service.VenueService) *GetVenueUseCase {
	return &GetVenueUseCase{
		venueService: venueService,
	}
}

func (uc *GetVenueUseCase) Execute(ctx context.Context, input dto.GetVenueInput) (*dto.GetVenueOutput, error) {
	venue, err := uc.venueService.GetVenue(ctx, input.VenueID)
	if err != nil {
		return nil, err
	}

	output := dto.ToVenueOutput(venue)
	return &output, nil
}

