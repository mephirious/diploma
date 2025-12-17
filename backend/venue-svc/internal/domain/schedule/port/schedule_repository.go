package port

import (
	"context"

	"github.com/diploma/venue-svc/internal/domain/schedule/entity"
	"github.com/google/uuid"
)

type ScheduleRepository interface {
	CreateBatch(ctx context.Context, slots []*entity.ScheduleSlot) error
	GetByResourceID(ctx context.Context, resourceID uuid.UUID) ([]*entity.ScheduleSlot, error)
	DeleteByResourceID(ctx context.Context, resourceID uuid.UUID) error
}

