package handler

import (
	"context"
	"fmt"
	"log"

	"github.com/diploma/notification-svc/internal/application/event/dto"
	"github.com/diploma/notification-svc/internal/domain/notification/port"
)

type PaymentEventHandler struct {
	notificationSender port.NotificationSender
}

func NewPaymentEventHandler(notificationSender port.NotificationSender) *PaymentEventHandler {
	return &PaymentEventHandler{
		notificationSender: notificationSender,
	}
}

func (h *PaymentEventHandler) HandlePaymentCreated(ctx context.Context, event dto.PaymentCreatedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Payment Initiated",
		Body:    fmt.Sprintf("Your payment of $%.2f for session %s has been initiated.", event.Amount, event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send payment created email: %v", err)
		return err
	}

	log.Printf("Sent payment created notification to user %s", event.UserID)
	return nil
}

func (h *PaymentEventHandler) HandlePaymentSucceeded(ctx context.Context, event dto.PaymentSucceededEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Payment Successful",
		Body:    fmt.Sprintf("Your payment of $%.2f for session %s was successful!", event.Amount, event.SessionID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send payment succeeded email: %v", err)
		return err
	}

	log.Printf("Sent payment succeeded notification to user %s", event.UserID)
	return nil
}

func (h *PaymentEventHandler) HandlePaymentFailed(ctx context.Context, event dto.PaymentFailedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Payment Failed",
		Body:    fmt.Sprintf("Your payment for session %s failed. Reason: %s. Please try again.", event.SessionID, event.Reason),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send payment failed email: %v", err)
		return err
	}

	log.Printf("Sent payment failed notification to user %s", event.UserID)
	return nil
}

func (h *PaymentEventHandler) HandlePaymentRefunded(ctx context.Context, event dto.PaymentRefundedEvent) error {
	notification := port.EmailNotification{
		To:      fmt.Sprintf("user-%s@example.com", event.UserID),
		Subject: "Payment Refunded",
		Body:    fmt.Sprintf("Your payment for session %s has been refunded. Refund ID: %s", event.SessionID, event.RefundID),
		IsHTML:  false,
	}

	if err := h.notificationSender.SendEmail(ctx, notification); err != nil {
		log.Printf("Failed to send payment refunded email: %v", err)
		return err
	}

	log.Printf("Sent payment refunded notification to user %s", event.UserID)
	return nil
}

