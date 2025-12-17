package email

import (
	"context"
	"fmt"
	"log"
	"net/smtp"

	"github.com/diploma/notification-svc/internal/domain/notification/port"
	pkgerrors "github.com/diploma/notification-svc/pkg/errors"
)

type SMTPSender struct {
	host     string
	port     string
	username string
	password string
	from     string
}

func NewSMTPSender(host, port, username, password, from string) *SMTPSender {
	return &SMTPSender{
		host:     host,
		port:     port,
		username: username,
		password: password,
		from:     from,
	}
}

func (s *SMTPSender) SendEmail(ctx context.Context, notification port.EmailNotification) error {
	if s.host == "" || s.host == "stub" {
		log.Printf("📧 [STUB] Email to %s: %s - %s", notification.To, notification.Subject, notification.Body)
		return nil
	}

	auth := smtp.PlainAuth("", s.username, s.password, s.host)

	message := fmt.Sprintf("From: %s\r\n", s.from)
	message += fmt.Sprintf("To: %s\r\n", notification.To)
	message += fmt.Sprintf("Subject: %s\r\n", notification.Subject)
	if notification.IsHTML {
		message += "Content-Type: text/html; charset=UTF-8\r\n"
	}
	message += "\r\n"
	message += notification.Body

	addr := fmt.Sprintf("%s:%s", s.host, s.port)
	err := smtp.SendMail(addr, auth, s.from, []string{notification.To}, []byte(message))
	if err != nil {
		return pkgerrors.NewExternalAPIError("failed to send email", err)
	}

	log.Printf("📧 Sent email to %s: %s", notification.To, notification.Subject)
	return nil
}

