package service

import (
	"context"
	"fmt"

	"github.com/diploma/venue-svc/internal/domain/venue/entity"
	"github.com/diploma/venue-svc/internal/domain/venue/port"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type VenueService struct {
	repo port.VenueRepository
}

func NewVenueService(repo port.VenueRepository) *VenueService {
	return &VenueService{
		repo: repo,
	}
}

func (s *VenueService) CreateVenue(ctx context.Context, ownerID uuid.UUID, name, description, city, address string, latitude, longitude float64) (*entity.Venue, error) {
	venue := &entity.Venue{
		ID:          uuid.New(),
		OwnerID:     ownerID,
		Name:        name,
		Description: description,
		City:        city,
		Address:     address,
		Latitude:    latitude,
		Longitude:   longitude,
	}

	if err := venue.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Create(ctx, venue); err != nil {
		return nil, fmt.Errorf("failed to create venue: %w", err)
	}

	return venue, nil
}

func (s *VenueService) GetVenue(ctx context.Context, id uuid.UUID) (*entity.Venue, error) {
	if id == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("venue_id is required")
	}
	return s.repo.GetByID(ctx, id)
}

func (s *VenueService) ListVenues(ctx context.Context, city string, page, pageSize int) ([]*entity.Venue, int, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	offset := (page - 1) * pageSize
	return s.repo.List(ctx, city, offset, pageSize)
}

func (s *VenueService) UpdateVenue(ctx context.Context, id uuid.UUID, name, description, city, address string, latitude, longitude float64) (*entity.Venue, error) {
	venue, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	venue.Update(name, description, city, address, latitude, longitude)

	if err := venue.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Update(ctx, venue); err != nil {
		return nil, fmt.Errorf("failed to update venue: %w", err)
	}

	return venue, nil
}

func (s *VenueService) DeleteVenue(ctx context.Context, id uuid.UUID) error {
	if id == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("venue_id is required")
	}

	return s.repo.Delete(ctx, id)
}

