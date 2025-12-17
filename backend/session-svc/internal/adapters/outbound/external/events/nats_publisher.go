package events

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/nats-io/nats.go"
)

type NATSEventPublisher struct {
	nc *nats.Conn
}

func NewNATSEventPublisher(nc *nats.Conn) *NATSEventPublisher {
	return &NATSEventPublisher{nc: nc}
}

type SessionCreatedEvent struct {
	SessionID     string `json:"session_id"`
	ReservationID string `json:"reservation_id"`
	HostID        string `json:"host_id"`
}

type SessionJoinedEvent struct {
	SessionID           string `json:"session_id"`
	UserID              string `json:"user_id"`
	CurrentParticipants int    `json:"current_participants"`
}

type SessionFullEvent struct {
	SessionID string `json:"session_id"`
}

type SessionCancelledEvent struct {
	SessionID string `json:"session_id"`
}

type SessionLeftEvent struct {
	SessionID string `json:"session_id"`
	UserID    string `json:"user_id"`
}

func (p *NATSEventPublisher) PublishSessionCreated(ctx context.Context, sessionID, reservationID, hostID uuid.UUID) error {
	event := SessionCreatedEvent{
		SessionID:     sessionID.String(),
		ReservationID: reservationID.String(),
		HostID:        hostID.String(),
	}
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}
	return p.nc.Publish("session.created", data)
}

func (p *NATSEventPublisher) PublishSessionJoined(ctx context.Context, sessionID, userID uuid.UUID, currentParticipants int) error {
	event := SessionJoinedEvent{
		SessionID:           sessionID.String(),
		UserID:              userID.String(),
		CurrentParticipants: currentParticipants,
	}
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}
	return p.nc.Publish("session.joined", data)
}

func (p *NATSEventPublisher) PublishSessionFull(ctx context.Context, sessionID uuid.UUID) error {
	event := SessionFullEvent{SessionID: sessionID.String()}
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}
	return p.nc.Publish("session.full", data)
}

func (p *NATSEventPublisher) PublishSessionCancelled(ctx context.Context, sessionID uuid.UUID) error {
	event := SessionCancelledEvent{SessionID: sessionID.String()}
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}
	return p.nc.Publish("session.cancelled", data)
}

func (p *NATSEventPublisher) PublishSessionLeft(ctx context.Context, sessionID, userID uuid.UUID) error {
	event := SessionLeftEvent{
		SessionID: sessionID.String(),
		UserID:    userID.String(),
	}
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}
	return p.nc.Publish("session.left", data)
}

