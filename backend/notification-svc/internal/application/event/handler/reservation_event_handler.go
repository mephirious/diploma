package handler

import (
	"context"
	"fmt"
	"log"

	"github.com/diploma/notification-svc/internal/application/event/dto"
	"github.com/diploma/notification-svc/internal/domain/notification/port"
)

type ReservationEventHandler struct {
	notificationSender port.NotificationSender
}

func NewReservationEventHandler(notificationSender port.NotificationSender) *ReservationEventHandler {
	return &ReservationEventHandler{
		notificationSender: notificationSender,
	}
}

func (h *ReservationEventHandler) HandleReservationCreated(ctx context.Context, event dto.ReservationCreatedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID), // TODO: Lookup actual email from auth-svc
		Subject: "Reservation Created",
		Body:    fmt.Sprintf("Your reservation %s has been created for %s.", event.ReservationID, event.ReservedAt),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send reservation created email: %v", err)
		return err
	}

	log.Printf("Sent reservation created notification to user %s", event.UserID)
	return nil
}

func (h *ReservationEventHandler) HandleReservationConfirmed(ctx context.Context, event dto.ReservationConfirmedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Reservation Confirmed",
		Body:    fmt.Sprintf("Your reservation %s has been confirmed!", event.ReservationID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send reservation confirmed email: %v", err)
		return err
	}

	log.Printf("Sent reservation confirmed notification to user %s", event.UserID)
	return nil
}

func (h *ReservationEventHandler) HandleReservationCancelled(ctx context.Context, event dto.ReservationCancelledEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Reservation Cancelled",
		Body:    fmt.Sprintf("Your reservation %s has been cancelled.", event.ReservationID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send reservation cancelled email: %v", err)
		return err
	}

	log.Printf("Sent reservation cancelled notification to user %s", event.UserID)
	return nil
}

