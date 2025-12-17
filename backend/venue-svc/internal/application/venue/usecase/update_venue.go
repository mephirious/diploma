package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/venue/dto"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
)

type UpdateVenueUseCase struct {
	venueService *service.VenueService
}

func NewUpdateVenueUseCase(venueService *service.VenueService) *UpdateVenueUseCase {
	return &UpdateVenueUseCase{
		venueService: venueService,
	}
}

func (uc *UpdateVenueUseCase) Execute(ctx context.Context, input dto.UpdateVenueInput) (*dto.UpdateVenueOutput, error) {
	_, err := uc.venueService.UpdateVenue(
		ctx,
		input.VenueID,
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

	return &dto.UpdateVenueOutput{
		Success: true,
	}, nil
}

