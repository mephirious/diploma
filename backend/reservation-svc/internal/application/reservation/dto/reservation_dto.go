package dto

import (
	"time"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/google/uuid"
)

type CreateReservationInput struct {
	UserID      uuid.UUID
	ApartmentID uuid.UUID
	Comment     *string
}

type CreateReservationOutput struct {
	ReservationID uuid.UUID
}

type ConfirmReservationInput struct {
	ReservationID uuid.UUID
}

type ConfirmReservationOutput struct {
	Success bool
}

type CancelReservationInput struct {
	ReservationID uuid.UUID
}

type CancelReservationOutput struct {
	Success bool
}

type GetReservationInput struct {
	ReservationID uuid.UUID
}

type GetReservationOutput struct {
	ID          uuid.UUID
	UserID      uuid.UUID
	ApartmentID uuid.UUID
	Status      string
	ReservedAt  time.Time
	ExpiresAt   *time.Time
	Comment     *string
}

type ListReservationsByUserInput struct {
	UserID uuid.UUID
}

type ListReservationsByUserOutput struct {
	Items []GetReservationOutput
}

func ToGetReservationOutput(reservation *entity.Reservation) GetReservationOutput {
	return GetReservationOutput{
		ID:          reservation.ID,
		UserID:      reservation.UserID,
		ApartmentID: reservation.ApartmentID,
		Status:      string(reservation.Status),
		ReservedAt:  reservation.ReservedAt,
		ExpiresAt:   reservation.ExpiresAt,
		Comment:     reservation.Comment,
	}
}

