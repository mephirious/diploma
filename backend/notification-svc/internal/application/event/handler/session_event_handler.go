package handler

import (
	"context"
	"fmt"
	"log"

	"github.com/diploma/notification-svc/internal/application/event/dto"
	"github.com/diploma/notification-svc/internal/domain/notification/port"
)

type SessionEventHandler struct {
	notificationSender port.NotificationSender
}

func NewSessionEventHandler(notificationSender port.NotificationSender) *SessionEventHandler {
	return &SessionEventHandler{
		notificationSender: notificationSender,
	}
}

func (h *SessionEventHandler) HandleSessionCreated(ctx context.Context, event dto.SessionCreatedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.HostID),
		Subject: "Session Created",
		Body:    fmt.Sprintf("Your game session %s has been created!", event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send session created email: %v", err)
		return err
	}

	log.Printf("Sent session created notification to host %s", event.HostID)
	return nil
}

func (h *SessionEventHandler) HandleSessionJoined(ctx context.Context, event dto.SessionJoinedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "You Joined a Session",
		Body:    fmt.Sprintf("You have successfully joined session %s!", event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send session joined email: %v", err)
		return err
	}

	log.Printf("Sent session joined notification to user %s", event.UserID)
	return nil
}

func (h *SessionEventHandler) HandleSessionFull(ctx context.Context, event dto.SessionFullEvent) error {
	notification := port.EmailNotification{
		To:      "participants@example.com", // TODO: Get all participant emails
		Subject: "Session is Full",
		Body:    fmt.Sprintf("Session %s is now full and ready to start!", event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send session full email: %v", err)
		return err
	}

	log.Printf("Sent session full notification for session %s", event.SessionID)
	return nil
}

func (h *SessionEventHandler) HandleSessionCancelled(ctx context.Context, event dto.SessionCancelledEvent) error {
	notification := port.EmailNotification{
		To:      "participants@example.com", // TODO: Get all participant emails
		Subject: "Session Cancelled",
		Body:    fmt.Sprintf("Session %s has been cancelled.", event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send session cancelled email: %v", err)
		return err
	}

	log.Printf("Sent session cancelled notification for session %s", event.SessionID)
	return nil
}

func (h *SessionEventHandler) HandleSessionLeft(ctx context.Context, event dto.SessionLeftEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "You Left the Session",
		Body:    fmt.Sprintf("You have left session %s.", event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send session left email: %v", err)
		return err
	}

	log.Printf("Sent session left notification to user %s", event.UserID)
	return nil
}

