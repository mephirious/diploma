package service

import (
	"context"
	"fmt"

	"github.com/diploma/auth-svc/internal/domain/user/entity"
	"github.com/diploma/auth-svc/internal/domain/user/port"
	pkgerrors "github.com/diploma/auth-svc/pkg/errors"
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
		return nil, pkgerrors.NewInvalidArgumentError("email is required")
	}
	if password == "" {
		return nil, pkgerrors.NewInvalidArgumentError("password is required")
	}

	existing, err := s.userRepo.GetByEmail(ctx, email)
	if err == nil && existing != nil {
		return nil, pkgerrors.NewAlreadyExistsError("user with this email already exists")
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, pkgerrors.NewInternalError("failed to hash password", err)
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
		return nil, pkgerrors.NewInvalidArgumentError("email is required")
	}
	return s.userRepo.GetByEmail(ctx, email)
}

func (s *UserService) GetByID(ctx context.Context, id string) (*entity.User, error) {
	if id == "" {
		return nil, pkgerrors.NewInvalidArgumentError("user id is required")
	}
	return s.userRepo.GetByID(ctx, id)
}

func (s *UserService) ValidatePassword(ctx context.Context, user *entity.User, password string) error {
	if user == nil {
		return pkgerrors.NewInvalidArgumentError("user is nil")
	}
	if password == "" {
		return pkgerrors.NewInvalidArgumentError("password is required")
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return pkgerrors.NewUnauthenticatedError("invalid password")
	}

	return nil
}
