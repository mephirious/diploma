package events

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/nats-io/nats.go"
)

type NATSPublisher struct {
	conn *nats.Conn
}

func NewNATSPublisher(conn *nats.Conn) *NATSPublisher {
	return &NATSPublisher{
		conn: conn,
	}
}

type ReservationCreatedEvent struct {
	ReservationID string `json:"reservation_id"`
	UserID        string `json:"user_id"`
	ApartmentID   string `json:"apartment_id"`
	Status        string `json:"status"`
	Timestamp     string `json:"timestamp"`
}

type ReservationConfirmedEvent struct {
	ReservationID string `json:"reservation_id"`
	Timestamp     string `json:"timestamp"`
}

type ReservationCancelledEvent struct {
	ReservationID string `json:"reservation_id"`
	Timestamp     string `json:"timestamp"`
}

func (p *NATSPublisher) PublishReservationCreated(ctx context.Context, reservationID, userID, apartmentID string) error {
	event := ReservationCreatedEvent{
		ReservationID: reservationID,
		UserID:        userID,
		ApartmentID:   apartmentID,
		Status:        "PENDING",
		Timestamp:     fmt.Sprintf("%d", ctx.Value("timestamp")),
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}

	if err := p.conn.Publish("RESERVATION.CREATED", data); err != nil {
		log.Printf("Failed to publish RESERVATION.CREATED: %v", err)
		return err
	}

	return nil
}

func (p *NATSPublisher) PublishReservationConfirmed(ctx context.Context, reservationID string) error {
	event := ReservationConfirmedEvent{
		ReservationID: reservationID,
		Timestamp:     fmt.Sprintf("%d", ctx.Value("timestamp")),
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}

	if err := p.conn.Publish("RESERVATION.CONFIRMED", data); err != nil {
		log.Printf("Failed to publish RESERVATION.CONFIRMED: %v", err)
		return err
	}

	return nil
}

func (p *NATSPublisher) PublishReservationCancelled(ctx context.Context, reservationID string) error {
	event := ReservationCancelledEvent{
		ReservationID: reservationID,
		Timestamp:     fmt.Sprintf("%d", ctx.Value("timestamp")),
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}

	if err := p.conn.Publish("RESERVATION.CANCELLED", data); err != nil {
		log.Printf("Failed to publish RESERVATION.CANCELLED: %v", err)
		return err
	}

	return nil
}

