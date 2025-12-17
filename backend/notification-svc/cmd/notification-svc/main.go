package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/diploma/notification-svc/internal/adapters/inbound/nats"
	"github.com/diploma/notification-svc/internal/adapters/outbound/email"
	"github.com/diploma/notification-svc/internal/application/event/handler"
	"github.com/diploma/notification-svc/internal/config"
	natsclient "github.com/nats-io/nats.go"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("failed to run notification service: %v", err)
	}
}

func run() error {
	log.Println("Starting notification-svc...")

	cfg, err := config.Load()
	if err != nil {
		return err
	}

	nc, err := natsclient.Connect(cfg.NATSConfig.URL)
	if err != nil {
		return err
	}
	defer nc.Close()
	log.Printf("Connected to NATS at %s", cfg.NATSConfig.URL)

	emailSender := email.NewSMTPSender(
		cfg.SMTPConfig.Host,
		cfg.SMTPConfig.Port,
		cfg.SMTPConfig.Username,
		cfg.SMTPConfig.Password,
		cfg.SMTPConfig.From,
	)
	log.Println("Email sender initialized")

	reservationEventHandler := handler.NewReservationEventHandler(emailSender)
	sessionEventHandler := handler.NewSessionEventHandler(emailSender)
	paymentEventHandler := handler.NewPaymentEventHandler(emailSender)

	eventSubscriber := nats.NewEventSubscriber(
		nc,
		reservationEventHandler,
		sessionEventHandler,
		paymentEventHandler,
	)

	ctx := context.Background()
	if err := eventSubscriber.SubscribeAll(ctx); err != nil {
		return err
	}

	log.Println("notification-svc is running and listening for events...")

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan

	log.Println("Shutting down notification-svc...")
	return nil
}

