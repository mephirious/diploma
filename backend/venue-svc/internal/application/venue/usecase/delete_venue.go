package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/venue/dto"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
)

type DeleteVenueUseCase struct {
	venueService *service.VenueService
}

func NewDeleteVenueUseCase(venueService *service.VenueService) *DeleteVenueUseCase {
	return &DeleteVenueUseCase{
		venueService: venueService,
	}
}

func (uc *DeleteVenueUseCase) Execute(ctx context.Context, input dto.DeleteVenueInput) (*dto.DeleteVenueOutput, error) {
	err := uc.venueService.DeleteVenue(ctx, input.VenueID)
	if err != nil {
		return nil, err
	}

	return &dto.DeleteVenueOutput{
		Success: true,
	}, nil
}

