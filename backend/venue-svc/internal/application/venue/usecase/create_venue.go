package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/venue/dto"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
)

type CreateVenueUseCase struct {
	venueService *service.VenueService
}

func NewCreateVenueUseCase(venueService *service.VenueService) *CreateVenueUseCase {
	return &CreateVenueUseCase{
		venueService: venueService,
	}
}

func (uc *CreateVenueUseCase) Execute(ctx context.Context, input dto.CreateVenueInput) (*dto.CreateVenueOutput, error) {
	venue, err := uc.venueService.CreateVenue(
		ctx,
		input.OwnerID,
		input.Name,
		input.Description,
		input.City,
		input.Address,
		input.Latitude,
		input.Longitude,
	)
	if err != nil {
		return nil, err
	}

	return &dto.CreateVenueOutput{
		VenueID: venue.ID,
	}, nil
}

