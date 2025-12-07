package port

import (
	"context"

	"github.com/diploma/auth-svc/internal/domain/auth/entity"
)

type AuthRepository interface {
	SaveRefreshToken(ctx context.Context, token *entity.Token) error

	GetRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error)

	DeleteRefreshToken(ctx context.Context, refreshToken string) error
}
