package email

import (
	"context"
	"fmt"
)

type EmailService struct {
}

func NewEmailService() *EmailService {
	return &EmailService{}
}

func (s *EmailService) SendWelcomeEmail(ctx context.Context, email, name string) error {

	fmt.Printf("[EMAIL SERVICE] Would send welcome email to: %s (%s)\n", email, name)
	return nil
}

func (s *EmailService) SendPasswordResetEmail(ctx context.Context, email, resetToken string) error {

	fmt.Printf("[EMAIL SERVICE] Would send password reset email to: %s\n", email)
	return nil
}
