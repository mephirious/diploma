package service

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/auth-svc/internal/domain/user/entity"
	"github.com/diploma/auth-svc/internal/domain/user/port"
	"golang.org/x/crypto/bcrypt"
)

type UserService struct {
	userRepo port.UserRepository
}

func NewUserService(userRepo port.UserRepository) *UserService {
	return &UserService{
		userRepo: userRepo,
	}
}

func (s *UserService) CreateUser(ctx context.Context, fullName, email, phone, password string) (*entity.User, error) {

	if email == "" {
		return nil, errors.New("email is required")
	}
	if password == "" {
		return nil, errors.New("password is required")
	}

	existing, err := s.userRepo.GetByEmail(ctx, email)
	if err == nil && existing != nil {
		return nil, errors.New("user with this email already exists")
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	user := &entity.User{
		FullName:     fullName,
		Email:        email,
		Phone:        phone,
		PasswordHash: string(passwordHash),
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return user, nil
}

func (s *UserService) GetByEmail(ctx context.Context, email string) (*entity.User, error) {
	if email == "" {
		return nil, errors.New("email is required")
	}
	return s.userRepo.GetByEmail(ctx, email)
}

func (s *UserService) ValidatePassword(ctx context.Context, user *entity.User, password string) error {
	if user == nil {
		return errors.New("user is nil")
	}
	if password == "" {
		return errors.New("password is required")
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return errors.New("invalid password")
	}

	return nil
}
