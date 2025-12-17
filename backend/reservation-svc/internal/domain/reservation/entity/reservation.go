package entity

import (
	"fmt"
	"time"

	pkgerrors "github.com/diploma/reservation-svc/pkg/errors"
	"github.com/google/uuid"
)

type ReservationStatus string

const (
	StatusPending   ReservationStatus = "PENDING"
	StatusConfirmed ReservationStatus = "CONFIRMED"
	StatusCancelled ReservationStatus = "CANCELLED"
)

type Reservation struct {
	ID          uuid.UUID
	UserID      uuid.UUID
	ApartmentID uuid.UUID
	Status      ReservationStatus
	ReservedAt  time.Time
	ExpiresAt   *time.Time
	Comment     *string
}

func (r *Reservation) IsValid() bool {
	return r.UserID != uuid.Nil && r.ApartmentID != uuid.Nil
}

func (r *Reservation) CanConfirm() bool {
	return r.Status == StatusPending
}

func (r *Reservation) CanCancel() bool {
	return r.Status == StatusPending || r.Status == StatusConfirmed
}

func (r *Reservation) Confirm() error {
	if !r.CanConfirm() {
		return pkgerrors.NewFailedPreconditionError(
			fmt.Sprintf("cannot confirm reservation with status %s", r.Status),
		)
	}
	r.Status = StatusConfirmed
	return nil
}

func (r *Reservation) Cancel() error {
	if !r.CanCancel() {
		return pkgerrors.NewFailedPreconditionError(
			fmt.Sprintf("cannot cancel reservation with status %s", r.Status),
		)
	}
	r.Status = StatusCancelled
	return nil
}

func (r *Reservation) IsExpired() bool {
	if r.ExpiresAt == nil {
		return false
	}
	return time.Now().After(*r.ExpiresAt)
}

