package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/auth-svc/internal/domain/auth/entity"
	"github.com/diploma/auth-svc/internal/domain/auth/port"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type AuthRepositoryImpl struct {
	db *gorm.DB
}

func NewAuthRepository(db *gorm.DB) port.AuthRepository {
	return &AuthRepositoryImpl{
		db: db,
	}
}

func (r *AuthRepositoryImpl) SaveRefreshToken(ctx context.Context, token *entity.Token) error {
	if token.ID == uuid.Nil {
		token.ID = uuid.New()
	}

	result := r.db.WithContext(ctx).Create(token)
	if result.Error != nil {
		return fmt.Errorf("failed to save refresh token: %w", result.Error)
	}

	return nil
}

func (r *AuthRepositoryImpl) GetRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error) {
	var token entity.Token
	result := r.db.WithContext(ctx).Where("refresh_token = ?", refreshToken).First(&token)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("refresh token not found: %w", result.Error)
		}
		return nil, fmt.Errorf("failed to get refresh token: %w", result.Error)
	}

	return &token, nil
}

func (r *AuthRepositoryImpl) DeleteRefreshToken(ctx context.Context, refreshToken string) error {
	result := r.db.WithContext(ctx).Where("refresh_token = ?", refreshToken).Delete(&entity.Token{})

	if result.Error != nil {
		return fmt.Errorf("failed to delete refresh token: %w", result.Error)
	}

	if result.RowsAffected == 0 {
		return fmt.Errorf("refresh token not found")
	}

	return nil
}
