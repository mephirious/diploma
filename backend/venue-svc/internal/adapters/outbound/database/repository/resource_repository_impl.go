package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/venue-svc/internal/domain/resource/entity"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ResourceRepositoryImpl struct {
	db *gorm.DB
}

func NewResourceRepository(db *gorm.DB) *ResourceRepositoryImpl {
	return &ResourceRepositoryImpl{
		db: db,
	}
}

func (r *ResourceRepositoryImpl) Create(ctx context.Context, resource *entity.Resource) error {
	result := r.db.WithContext(ctx).Create(resource)
	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to create resource", result.Error)
	}

	return nil
}

func (r *ResourceRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Resource, error) {
	var resource entity.Resource
	result := r.db.WithContext(ctx).Where("id = ?", id).First(&resource)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError(fmt.Sprintf("resource not found: %s", id))
		}
		return nil, pkgerrors.NewInternalError("failed to get resource", result.Error)
	}

	return &resource, nil
}

func (r *ResourceRepositoryImpl) ListByVenueID(ctx context.Context, venueID uuid.UUID, activeOnly bool) ([]*entity.Resource, error) {
	var resources []*entity.Resource
	query := r.db.WithContext(ctx).Where("venue_id = ?", venueID)

	if activeOnly {
		query = query.Where("is_active = ?", true)
	}

	result := query.Order("created_at DESC").Find(&resources)

	if result.Error != nil {
		return nil, pkgerrors.NewInternalError("failed to list resources", result.Error)
	}

	return resources, nil
}

func (r *ResourceRepositoryImpl) Update(ctx context.Context, resource *entity.Resource) error {
	result := r.db.WithContext(ctx).Model(&entity.Resource{}).Where("id = ?", resource.ID).Updates(map[string]interface{}{
		"name":         resource.Name,
		"sport_type":   resource.SportType,
		"capacity":     resource.Capacity,
		"surface_type": resource.SurfaceType,
		"is_active":    resource.IsActive,
	})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to update resource", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("resource not found: %s", resource.ID))
	}

	return nil
}

func (r *ResourceRepositoryImpl) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Where("id = ?", id).Delete(&entity.Resource{})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to delete resource", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("resource not found: %s", id))
	}

	return nil
}
