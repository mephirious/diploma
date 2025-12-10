package usecase

import "context"

type EventPublisher interface {
	PublishReservationCreated(ctx context.Context, reservationID, userID, apartmentID string) error
	PublishReservationConfirmed(ctx context.Context, reservationID string) error
	PublishReservationCancelled(ctx context.Context, reservationID string) error
}

