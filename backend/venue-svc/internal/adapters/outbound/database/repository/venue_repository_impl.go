package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/venue-svc/internal/domain/venue/entity"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VenueRepositoryImpl struct {
	db *gorm.DB
}

func NewVenueRepository(db *gorm.DB) *VenueRepositoryImpl {
	return &VenueRepositoryImpl{
		db: db,
	}
}

func (r *VenueRepositoryImpl) Create(ctx context.Context, venue *entity.Venue) error {
	result := r.db.WithContext(ctx).Create(venue)
	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to create venue", result.Error)
	}

	return nil
}

func (r *VenueRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Venue, error) {
	var venue entity.Venue
	result := r.db.WithContext(ctx).Where("id = ?", id).First(&venue)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError(fmt.Sprintf("venue not found: %s", id))
		}
		return nil, pkgerrors.NewInternalError("failed to get venue", result.Error)
	}

	return &venue, nil
}

func (r *VenueRepositoryImpl) List(ctx context.Context, city string, offset, limit int) ([]*entity.Venue, int, error) {
	var totalCount int64
	query := r.db.WithContext(ctx).Model(&entity.Venue{})

	if city != "" {
		query = query.Where("city = ?", city)
	}

	if err := query.Count(&totalCount).Error; err != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to count venues", err)
	}

	var venues []*entity.Venue
	result := query.Order("created_at DESC").Offset(offset).Limit(limit).Find(&venues)

	if result.Error != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to list venues", result.Error)
	}

	return venues, int(totalCount), nil
}

func (r *VenueRepositoryImpl) Update(ctx context.Context, venue *entity.Venue) error {
	result := r.db.WithContext(ctx).Model(&entity.Venue{}).Where("id = ?", venue.ID).Updates(map[string]interface{}{
		"name":        venue.Name,
		"description": venue.Description,
		"city":        venue.City,
		"address":     venue.Address,
		"latitude":    venue.Latitude,
		"longitude":   venue.Longitude,
	})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to update venue", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("venue not found: %s", venue.ID))
	}

	return nil
}

func (r *VenueRepositoryImpl) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Where("id = ?", id).Delete(&entity.Venue{})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to delete venue", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("venue not found: %s", id))
	}

	return nil
}
