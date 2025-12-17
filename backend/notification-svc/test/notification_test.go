package test

import (
	"context"
	"testing"

	"github.com/google/uuid"
)

type MockNotificationSender struct {
	sentCount int
}

func (m *MockNotificationSender) SendEmail(ctx context.Context, to, subject, body string) error {
	m.sentCount++
	return nil
}

func (m *MockNotificationSender) SendSMS(ctx context.Context, to, message string) error {
	m.sentCount++
	return nil
}

func TestMockNotificationSender(t *testing.T) {
	sender := &MockNotificationSender{}

	ctx := context.Background()
	err := sender.SendEmail(ctx, "test@example.com", "Test Subject", "Test Body")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if sender.sentCount != 1 {
		t.Errorf("Expected 1 notification sent, got %d", sender.sentCount)
	}
}

func TestMultipleNotifications(t *testing.T) {
	sender := &MockNotificationSender{}
	ctx := context.Background()

	sender.SendEmail(ctx, "user1@example.com", "Reservation Confirmed", "Your reservation is confirmed")
	sender.SendEmail(ctx, "user2@example.com", "Session Created", "New session available")
	sender.SendSMS(ctx, "+1234567890", "Payment received")

	if sender.sentCount != 3 {
		t.Errorf("Expected 3 notifications, got %d", sender.sentCount)
	}
}

func TestUUIDGeneration(t *testing.T) {
	id1 := uuid.New()
	id2 := uuid.New()

	if id1 == id2 {
		t.Error("Expected different UUIDs")
	}

	if id1 == uuid.Nil {
		t.Error("Expected valid UUID, got Nil")
	}
}

