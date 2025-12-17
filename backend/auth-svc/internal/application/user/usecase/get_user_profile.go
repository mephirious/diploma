package usecase

import (
	"context"
	"fmt"

	"github.com/diploma/auth-svc/internal/application/user/dto"
	"github.com/diploma/auth-svc/internal/domain/user/service"
)

type GetUserProfileUseCase struct {
	userService *service.UserService
}

func NewGetUserProfileUseCase(userService *service.UserService) *GetUserProfileUseCase {
	return &GetUserProfileUseCase{
		userService: userService,
	}
}

func (uc *GetUserProfileUseCase) Execute(ctx context.Context, input dto.GetUserProfileInput) (*dto.GetUserProfileOutput, error) {
	user, err := uc.userService.GetByID(ctx, input.UserID)
	if err != nil {
		return nil, fmt.Errorf("failed to get user profile: %w", err)
	}

	return &dto.GetUserProfileOutput{
		User: dto.UserDTO{
			ID:        user.ID.String(),
			FullName:  user.FullName,
			Email:     user.Email,
			Phone:     user.Phone,
			CreatedAt: user.CreatedAt,
		},
	}, nil
}

