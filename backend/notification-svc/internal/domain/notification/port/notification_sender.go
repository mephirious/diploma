package port

import "context"

type EmailNotification struct {
	To      string
	Subject string
	Body    string
	IsHTML  bool
}

type NotificationSender interface {
	SendEmail(ctx context.Context, notification EmailNotification) error
}

