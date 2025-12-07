package usecase

import (
	"context"
	"errors"
	"fmt"

	authservice "github.com/diploma/auth-svc/internal/domain/auth/service"
	userservice "github.com/diploma/auth-svc/internal/domain/user/service"
)

type LoginUserUseCase struct {
	userService *userservice.UserService
	authService *authservice.AuthService
}

func NewLoginUserUseCase(userService *userservice.UserService, authService *authservice.AuthService) *LoginUserUseCase {
	return &LoginUserUseCase{
		userService: userService,
		authService: authService,
	}
}

type LoginUserInput struct {
	Email    string
	Password string
}

type LoginUserOutput struct {
	AccessToken  string
	RefreshToken string
}

func (uc *LoginUserUseCase) Execute(ctx context.Context, input LoginUserInput) (*LoginUserOutput, error) {

	user, err := uc.userService.GetByEmail(ctx, input.Email)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	if err := uc.userService.ValidatePassword(ctx, user, input.Password); err != nil {
		return nil, errors.New("invalid email or password")
	}

	accessToken, err := uc.authService.GenerateToken(user.ID.String(), user.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	refreshToken, err := uc.authService.GenerateRefreshToken()
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	if err := uc.authService.SaveRefreshToken(ctx, user.ID.String(), refreshToken); err != nil {
		return nil, fmt.Errorf("failed to save refresh token: %w", err)
	}

	return &LoginUserOutput{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
