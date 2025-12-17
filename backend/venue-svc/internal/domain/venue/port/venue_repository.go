package port

import (
	"context"

	"github.com/diploma/venue-svc/internal/domain/venue/entity"
	"github.com/google/uuid"
)

type VenueRepository interface {
	Create(ctx context.Context, venue *entity.Venue) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Venue, error)
	List(ctx context.Context, city string, offset, limit int) ([]*entity.Venue, int, error)
	Update(ctx context.Context, venue *entity.Venue) error
	Delete(ctx context.Context, id uuid.UUID) error
}

