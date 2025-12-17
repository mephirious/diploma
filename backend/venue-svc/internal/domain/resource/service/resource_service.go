package service

import (
	"context"
	"fmt"

	"github.com/diploma/venue-svc/internal/domain/resource/entity"
	"github.com/diploma/venue-svc/internal/domain/resource/port"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type ResourceService struct {
	repo port.ResourceRepository
}

func NewResourceService(repo port.ResourceRepository) *ResourceService {
	return &ResourceService{
		repo: repo,
	}
}

func (s *ResourceService) CreateResource(ctx context.Context, venueID uuid.UUID, name, sportType, surfaceType string, capacity int, isActive bool) (*entity.Resource, error) {
	resource := &entity.Resource{
		ID:          uuid.New(),
		VenueID:     venueID,
		Name:        name,
		SportType:   sportType,
		Capacity:    capacity,
		SurfaceType: surfaceType,
		IsActive:    isActive,
	}

	if err := resource.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Create(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to create resource: %w", err)
	}

	return resource, nil
}

func (s *ResourceService) GetResource(ctx context.Context, id uuid.UUID) (*entity.Resource, error) {
	if id == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("resource_id is required")
	}
	return s.repo.GetByID(ctx, id)
}

func (s *ResourceService) ListResourcesByVenue(ctx context.Context, venueID uuid.UUID, activeOnly bool) ([]*entity.Resource, error) {
	if venueID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("venue_id is required")
	}
	return s.repo.ListByVenueID(ctx, venueID, activeOnly)
}

func (s *ResourceService) UpdateResource(ctx context.Context, id uuid.UUID, name, sportType, surfaceType string, capacity int, isActive bool) (*entity.Resource, error) {
	resource, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	resource.Update(name, sportType, surfaceType, capacity, isActive)

	if err := resource.IsValid(); err != nil {
		return nil, err
	}

	if err := s.repo.Update(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to update resource: %w", err)
	}

	return resource, nil
}

func (s *ResourceService) DeleteResource(ctx context.Context, id uuid.UUID) error {
	if id == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("resource_id is required")
	}

	return s.repo.Delete(ctx, id)
}

