package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/port"
	pkgerrors "github.com/diploma/reservation-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ReservationRepositoryImpl struct {
	db *gorm.DB
}

func NewReservationRepository(db *gorm.DB) port.ReservationRepository {
	return &ReservationRepositoryImpl{
		db: db,
	}
}

func (r *ReservationRepositoryImpl) Create(ctx context.Context, reservation *entity.Reservation) error {
	result := r.db.WithContext(ctx).Create(reservation)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			return pkgerrors.NewConflictError("reservation already exists or conflicts with existing reservation")
		}
		if errors.Is(result.Error, gorm.ErrForeignKeyViolated) {
			return pkgerrors.NewInvalidArgumentError("invalid user_id or apartment_id reference")
		}
		return fmt.Errorf("failed to create reservation: %w", result.Error)
	}

	return nil
}

func (r *ReservationRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	var reservation entity.Reservation
	result := r.db.WithContext(ctx).Where("id = ?", id).First(&reservation)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError("reservation not found")
		}
		return nil, fmt.Errorf("failed to get reservation: %w", result.Error)
	}

	return &reservation, nil
}

func (r *ReservationRepositoryImpl) Update(ctx context.Context, reservation *entity.Reservation) error {
	result := r.db.WithContext(ctx).Model(&entity.Reservation{}).Where("id = ?", reservation.ID).Updates(map[string]interface{}{
		"status":     reservation.Status,
		"expires_at": reservation.ExpiresAt,
		"comment":    reservation.Comment,
	})

	if result.Error != nil {
		return fmt.Errorf("failed to update reservation: %w", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError("reservation not found")
	}

	return nil
}

func (r *ReservationRepositoryImpl) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	var reservations []*entity.Reservation
	result := r.db.WithContext(ctx).Where("user_id = ?", userID).Order("reserved_at DESC").Find(&reservations)

	if result.Error != nil {
		return nil, fmt.Errorf("failed to list reservations: %w", result.Error)
	}

	return reservations, nil
}
