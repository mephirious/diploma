package port

import (
	"context"

	"github.com/diploma/venue-svc/internal/domain/resource/entity"
	"github.com/google/uuid"
)

type ResourceRepository interface {
	Create(ctx context.Context, resource *entity.Resource) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Resource, error)
	ListByVenueID(ctx context.Context, venueID uuid.UUID, activeOnly bool) ([]*entity.Resource, error)
	Update(ctx context.Context, resource *entity.Resource) error
	Delete(ctx context.Context, id uuid.UUID) error
}

