package dto

import (
	"time"

	venueEntity "github.com/diploma/venue-svc/internal/domain/venue/entity"
	"github.com/google/uuid"
)

type CreateVenueInput struct {
	OwnerID     uuid.UUID
	Name        string
	Description string
	City        string
	Address     string
	Latitude    float64
	Longitude   float64
}

type CreateVenueOutput struct {
	VenueID uuid.UUID
}

type GetVenueInput struct {
	VenueID uuid.UUID
}

type GetVenueOutput struct {
	ID          uuid.UUID
	OwnerID     uuid.UUID
	Name        string
	Description string
	City        string
	Address     string
	Latitude    float64
	Longitude   float64
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type ListVenuesInput struct {
	City     string
	Page     int
	PageSize int
}

type ListVenuesOutput struct {
	Items      []GetVenueOutput
	TotalCount int
}

type UpdateVenueInput struct {
	VenueID     uuid.UUID
	Name        string
	Description string
	City        string
	Address     string
	Latitude    float64
	Longitude   float64
}

type UpdateVenueOutput struct {
	Success bool
}

type DeleteVenueInput struct {
	VenueID uuid.UUID
}

type DeleteVenueOutput struct {
	Success bool
}

func ToVenueOutput(venue *venueEntity.Venue) GetVenueOutput {
	return GetVenueOutput{
		ID:          venue.ID,
		OwnerID:     venue.OwnerID,
		Name:        venue.Name,
		Description: venue.Description,
		City:        venue.City,
		Address:     venue.Address,
		Latitude:    venue.Latitude,
		Longitude:   venue.Longitude,
		CreatedAt:   venue.CreatedAt,
		UpdatedAt:   venue.UpdatedAt,
	}
}

