package nats

import (
	"context"
	"encoding/json"
	"log"

	"github.com/diploma/notification-svc/internal/application/event/dto"
	"github.com/diploma/notification-svc/internal/application/event/handler"
	"github.com/nats-io/nats.go"
)

type EventSubscriber struct {
	nc                      *nats.Conn
	reservationEventHandler *handler.ReservationEventHandler
	sessionEventHandler     *handler.SessionEventHandler
	paymentEventHandler     *handler.PaymentEventHandler
}

func NewEventSubscriber(
	nc *nats.Conn,
	reservationEventHandler *handler.ReservationEventHandler,
	sessionEventHandler *handler.SessionEventHandler,
	paymentEventHandler *handler.PaymentEventHandler,
) *EventSubscriber {
	return &EventSubscriber{
		nc:                      nc,
		reservationEventHandler: reservationEventHandler,
		sessionEventHandler:     sessionEventHandler,
		paymentEventHandler:     paymentEventHandler,
	}
}

func (s *EventSubscriber) SubscribeAll(ctx context.Context) error {
	if _, err := s.nc.Subscribe("reservation.created", s.handleReservationCreated); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("reservation.confirmed", s.handleReservationConfirmed); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("reservation.cancelled", s.handleReservationCancelled); err != nil {
		return err
	}

	if _, err := s.nc.Subscribe("session.created", s.handleSessionCreated); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("session.joined", s.handleSessionJoined); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("session.full", s.handleSessionFull); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("session.cancelled", s.handleSessionCancelled); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("session.left", s.handleSessionLeft); err != nil {
		return err
	}

	if _, err := s.nc.Subscribe("payment.created", s.handlePaymentCreated); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("payment.succeeded", s.handlePaymentSucceeded); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("payment.failed", s.handlePaymentFailed); err != nil {
		return err
	}
	if _, err := s.nc.Subscribe("payment.refunded", s.handlePaymentRefunded); err != nil {
		return err
	}

	log.Println("Subscribed to all NATS events")
	return nil
}

func (s *EventSubscriber) handleReservationCreated(msg *nats.Msg) {
	var event dto.ReservationCreatedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal reservation.created event: %v", err)
		return
	}
	_ = s.reservationEventHandler.HandleReservationCreated(context.Background(), event)
}

func (s *EventSubscriber) handleReservationConfirmed(msg *nats.Msg) {
	var event dto.ReservationConfirmedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal reservation.confirmed event: %v", err)
		return
	}
	_ = s.reservationEventHandler.HandleReservationConfirmed(context.Background(), event)
}

func (s *EventSubscriber) handleReservationCancelled(msg *nats.Msg) {
	var event dto.ReservationCancelledEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal reservation.cancelled event: %v", err)
		return
	}
	_ = s.reservationEventHandler.HandleReservationCancelled(context.Background(), event)
}

func (s *EventSubscriber) handleSessionCreated(msg *nats.Msg) {
	var event dto.SessionCreatedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal session.created event: %v", err)
		return
	}
	_ = s.sessionEventHandler.HandleSessionCreated(context.Background(), event)
}

func (s *EventSubscriber) handleSessionJoined(msg *nats.Msg) {
	var event dto.SessionJoinedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal session.joined event: %v", err)
		return
	}
	_ = s.sessionEventHandler.HandleSessionJoined(context.Background(), event)
}

func (s *EventSubscriber) handleSessionFull(msg *nats.Msg) {
	var event dto.SessionFullEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal session.full event: %v", err)
		return
	}
	_ = s.sessionEventHandler.HandleSessionFull(context.Background(), event)
}

func (s *EventSubscriber) handleSessionCancelled(msg *nats.Msg) {
	var event dto.SessionCancelledEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal session.cancelled event: %v", err)
		return
	}
	_ = s.sessionEventHandler.HandleSessionCancelled(context.Background(), event)
}

func (s *EventSubscriber) handleSessionLeft(msg *nats.Msg) {
	var event dto.SessionLeftEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal session.left event: %v", err)
		return
	}
	_ = s.sessionEventHandler.HandleSessionLeft(context.Background(), event)
}

func (s *EventSubscriber) handlePaymentCreated(msg *nats.Msg) {
	var event dto.PaymentCreatedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal payment.created event: %v", err)
		return
	}
	_ = s.paymentEventHandler.HandlePaymentCreated(context.Background(), event)
}

func (s *EventSubscriber) handlePaymentSucceeded(msg *nats.Msg) {
	var event dto.PaymentSucceededEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal payment.succeeded event: %v", err)
		return
	}
	_ = s.paymentEventHandler.HandlePaymentSucceeded(context.Background(), event)
}

func (s *EventSubscriber) handlePaymentFailed(msg *nats.Msg) {
	var event dto.PaymentFailedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal payment.failed event: %v", err)
		return
	}
	_ = s.paymentEventHandler.HandlePaymentFailed(context.Background(), event)
}

func (s *EventSubscriber) handlePaymentRefunded(msg *nats.Msg) {
	var event dto.PaymentRefundedEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal payment.refunded event: %v", err)
		return
	}
	_ = s.paymentEventHandler.HandlePaymentRefunded(context.Background(), event)
}

