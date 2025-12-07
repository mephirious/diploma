package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/auth-svc/internal/domain/user/service"
)

type RegisterUserUseCase struct {
	userService *service.UserService
}

func NewRegisterUserUseCase(userService *service.UserService) *RegisterUserUseCase {
	return &RegisterUserUseCase{
		userService: userService,
	}
}

type RegisterUserInput struct {
	FullName string
	Email    string
	Phone    string
	Password string
}

type RegisterUserOutput struct {
	UserID string
}

func (uc *RegisterUserUseCase) Execute(ctx context.Context, input RegisterUserInput) (*RegisterUserOutput, error) {
	user, err := uc.userService.CreateUser(ctx, input.FullName, input.Email, input.Phone, input.Password)
	if err != nil {
		return nil, fmt.Errorf("failed to register user: %w", err)
	}

	return &RegisterUserOutput{
		UserID: user.ID.String(),
	}, nil
}
