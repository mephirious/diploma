package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/auth-svc/internal/application/user/dto"
	authservice "github.com/diploma/auth-svc/internal/domain/auth/service"
	userservice "github.com/diploma/auth-svc/internal/domain/user/service"
	pkgerrors "github.com/diploma/auth-svc/pkg/errors"
)

type RefreshTokenUseCase struct {
	authService *authservice.AuthService
	userService *userservice.UserService
}

func NewRefreshTokenUseCase(authService *authservice.AuthService, userService *userservice.UserService) *RefreshTokenUseCase {
	return &RefreshTokenUseCase{
		authService: authService,
		userService: userService,
	}
}

func (uc *RefreshTokenUseCase) Execute(ctx context.Context, input dto.RefreshTokenInput) (*dto.RefreshTokenOutput, error) {
	userID, err := uc.authService.ValidateRefreshToken(ctx, input.RefreshToken)
	if err != nil {
		return nil, pkgerrors.NewUnauthenticatedError("invalid or expired refresh token")
	}

	user, err := uc.userService.GetByID(ctx, userID)
	if err != nil {
		return nil, pkgerrors.NewUnauthenticatedError("user not found")
	}

	accessToken, err := uc.authService.GenerateToken(user.ID.String(), user.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	newRefreshToken, err := uc.authService.GenerateRefreshToken()
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	if err := uc.authService.DeleteRefreshToken(ctx, input.RefreshToken); err != nil {
		fmt.Printf("Warning: Failed to delete old refresh token: %v\n", err)
	}

	if err := uc.authService.SaveRefreshToken(ctx, user.ID.String(), newRefreshToken); err != nil {
		return nil, fmt.Errorf("failed to save refresh token: %w", err)
	}

	return &dto.RefreshTokenOutput{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	}, nil
}

