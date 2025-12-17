package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/auth-svc/internal/domain/user/entity"
	"github.com/diploma/auth-svc/internal/domain/user/port"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRepositoryImpl struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) port.UserRepository {
	return &UserRepositoryImpl{
		db: db,
	}
}

func (r *UserRepositoryImpl) Create(ctx context.Context, user *entity.User) error {
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}

	result := r.db.WithContext(ctx).Create(user)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			return fmt.Errorf("user with this email already exists")
		}
		return fmt.Errorf("failed to create user: %w", result.Error)
	}

	return nil
}

func (r *UserRepositoryImpl) GetByEmail(ctx context.Context, email string) (*entity.User, error) {
	var user entity.User
	result := r.db.WithContext(ctx).Where("email = ?", email).First(&user)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("user not found: %w", result.Error)
		}
		return nil, fmt.Errorf("failed to get user by email: %w", result.Error)
	}

	return &user, nil
}

func (r *UserRepositoryImpl) GetByID(ctx context.Context, id string) (*entity.User, error) {
	userID, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	var user entity.User
	result := r.db.WithContext(ctx).Where("id = ?", userID).First(&user)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("user not found: %w", result.Error)
		}
		return nil, fmt.Errorf("failed to get user by ID: %w", result.Error)
	}

	return &user, nil
}
