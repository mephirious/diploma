package repository

import (
	"context"

	"github.com/diploma/venue-svc/internal/domain/schedule/entity"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ScheduleRepositoryImpl struct {
	db *gorm.DB
}

func NewScheduleRepository(db *gorm.DB) *ScheduleRepositoryImpl {
	return &ScheduleRepositoryImpl{
		db: db,
	}
}

func (r *ScheduleRepositoryImpl) CreateBatch(ctx context.Context, slots []*entity.ScheduleSlot) error {
	if len(slots) == 0 {
		return nil
	}

	result := r.db.WithContext(ctx).Create(&slots)
	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to create schedule slots", result.Error)
	}

	return nil
}

func (r *ScheduleRepositoryImpl) GetByResourceID(ctx context.Context, resourceID uuid.UUID) ([]*entity.ScheduleSlot, error) {
	var slots []*entity.ScheduleSlot
	result := r.db.WithContext(ctx).Where("resource_id = ?", resourceID).Order("day_of_week, start_time").Find(&slots)

	if result.Error != nil {
		return nil, pkgerrors.NewInternalError("failed to get schedule slots", result.Error)
	}

	return slots, nil
}

func (r *ScheduleRepositoryImpl) DeleteByResourceID(ctx context.Context, resourceID uuid.UUID) error {
	result := r.db.WithContext(ctx).Where("resource_id = ?", resourceID).Delete(&entity.ScheduleSlot{})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to delete schedule slots", result.Error)
	}

	return nil
}
