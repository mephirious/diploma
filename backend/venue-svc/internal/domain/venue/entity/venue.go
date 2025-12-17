package entity

import (
	"time"

	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type Venue struct {
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

func (v *Venue) IsValid() error {
	if v.OwnerID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("owner_id is required")
	}
	if v.Name == "" {
		return pkgerrors.NewInvalidArgumentError("name is required")
	}
	if v.City == "" {
		return pkgerrors.NewInvalidArgumentError("city is required")
	}
	if v.Address == "" {
		return pkgerrors.NewInvalidArgumentError("address is required")
	}
	return nil
}

func (v *Venue) Update(name, description, city, address string, latitude, longitude float64) {
	if name != "" {
		v.Name = name
	}
	if description != "" {
		v.Description = description
	}
	if city != "" {
		v.City = city
	}
	if address != "" {
		v.Address = address
	}
	if latitude != 0 {
		v.Latitude = latitude
	}
	if longitude != 0 {
		v.Longitude = longitude
	}
	v.UpdatedAt = time.Now()
}

