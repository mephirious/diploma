package dto

import (
	"time"

	resourceEntity "github.com/diploma/venue-svc/internal/domain/resource/entity"
	"github.com/google/uuid"
)

type CreateResourceInput struct {
	VenueID     uuid.UUID
	Name        string
	SportType   string
	Capacity    int
	SurfaceType string
	IsActive    bool
}

type CreateResourceOutput struct {
	ResourceID uuid.UUID
}

type GetResourceInput struct {
	ResourceID uuid.UUID
}

type GetResourceOutput struct {
	ID          uuid.UUID
	VenueID     uuid.UUID
	Name        string
	SportType   string
	Capacity    int
	SurfaceType string
	IsActive    bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type ListResourcesByVenueInput struct {
	VenueID    uuid.UUID
	ActiveOnly bool
}

type ListResourcesByVenueOutput struct {
	Items []GetResourceOutput
}

type UpdateResourceInput struct {
	ResourceID  uuid.UUID
	Name        string
	SportType   string
	Capacity    int
	SurfaceType string
	IsActive    bool
}

type UpdateResourceOutput struct {
	Success bool
}

type DeleteResourceInput struct {
	ResourceID uuid.UUID
}

type DeleteResourceOutput struct {
	Success bool
}

func ToResourceOutput(resource *resourceEntity.Resource) GetResourceOutput {
	return GetResourceOutput{
		ID:          resource.ID,
		VenueID:     resource.VenueID,
		Name:        resource.Name,
		SportType:   resource.SportType,
		Capacity:    resource.Capacity,
		SurfaceType: resource.SurfaceType,
		IsActive:    resource.IsActive,
		CreatedAt:   resource.CreatedAt,
		UpdatedAt:   resource.UpdatedAt,
	}
}

