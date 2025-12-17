package entity

import (
	"time"

	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type Resource struct {
	ID          uuid.UUID
	VenueID     uuid.UUID
	Name        string
	SportType   string // tennis, football, basketball, etc.
	Capacity    int
	SurfaceType string // grass, clay, hardcourt, etc.
	IsActive    bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

func (r *Resource) IsValid() error {
	if r.VenueID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("venue_id is required")
	}
	if r.Name == "" {
		return pkgerrors.NewInvalidArgumentError("name is required")
	}
	if r.SportType == "" {
		return pkgerrors.NewInvalidArgumentError("sport_type is required")
	}
	if r.Capacity <= 0 {
		return pkgerrors.NewInvalidArgumentError("capacity must be positive")
	}
	return nil
}

func (r *Resource) Activate() {
	r.IsActive = true
	r.UpdatedAt = time.Now()
}

func (r *Resource) Deactivate() {
	r.IsActive = false
	r.UpdatedAt = time.Now()
}

func (r *Resource) Update(name, sportType, surfaceType string, capacity int, isActive bool) {
	if name != "" {
		r.Name = name
	}
	if sportType != "" {
		r.SportType = sportType
	}
	if surfaceType != "" {
		r.SurfaceType = surfaceType
	}
	if capacity > 0 {
		r.Capacity = capacity
	}
	r.IsActive = isActive
	r.UpdatedAt = time.Now()
}

