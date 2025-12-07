package test

import (
	"context"
	"testing"
	"time"

	"github.com/diploma/auth-svc/internal/config"
	"github.com/diploma/auth-svc/internal/domain/auth/entity"
	"github.com/diploma/auth-svc/internal/domain/auth/service"
	"golang.org/x/crypto/bcrypt"
)

type MockAuthRepository struct{}

func (m *MockAuthRepository) SaveRefreshToken(ctx context.Context, token *entity.Token) error {
	return nil
}

func (m *MockAuthRepository) GetRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error) {
	return nil, nil
}

func (m *MockAuthRepository) DeleteRefreshToken(ctx context.Context, refreshToken string) error {
	return nil
}

type MockUserRepository struct{}

func (m *MockUserRepository) Create(ctx interface{}, user interface{}) error {
	return nil
}

func (m *MockUserRepository) GetByEmail(ctx interface{}, email string) (interface{}, error) {
	return nil, nil
}

func TestHashPassword(t *testing.T) {
	password := "testPassword123!"

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		t.Fatalf("Failed to hash password: %v", err)
	}

	if len(hashedPassword) == 0 {
		t.Error("Hashed password should not be empty")
	}

	if string(hashedPassword) == password {
		t.Error("Hashed password should be different from plain text password")
	}

	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		t.Errorf("Failed to validate password against hash: %v", err)
	}

	wrongPassword := "wrongPassword"
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(wrongPassword))
	if err == nil {
		t.Error("Incorrect password should not validate")
	}
}

func TestValidatePassword(t *testing.T) {
	password := "correctPassword123!"
	wrongPassword := "wrongPassword"

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		t.Fatalf("Failed to hash password: %v", err)
	}

	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		t.Errorf("Correct password should validate: %v", err)
	}

	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(wrongPassword))
	if err == nil {
		t.Error("Incorrect password should not validate")
	}
}

func TestGenerateToken(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	mockRepo := &MockAuthRepository{}
	authService := service.NewAuthService(mockRepo, cfg)

	userID := "123e4567-e89b-12d3-a456-426614174000"
	email := "test@example.com"

	token, err := authService.GenerateToken(userID, email)
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	if token == "" {
		t.Error("Generated token should not be empty")
	}

	validatedUserID, isValid, err := authService.ValidateToken(token)
	if err != nil {
		t.Errorf("Failed to validate token: %v", err)
	}
	if !isValid {
		t.Error("Generated token should be valid")
	}
	if validatedUserID != userID {
		t.Errorf("Expected user ID %s, got %s", userID, validatedUserID)
	}
}

func TestGenerateRefreshToken(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	mockRepo := &MockAuthRepository{}
	authService := service.NewAuthService(mockRepo, cfg)

	refreshToken, err := authService.GenerateRefreshToken()
	if err != nil {
		t.Fatalf("Failed to generate refresh token: %v", err)
	}

	if refreshToken == "" {
		t.Error("Generated refresh token should not be empty")
	}

	refreshToken2, err := authService.GenerateRefreshToken()
	if err != nil {
		t.Fatalf("Failed to generate second refresh token: %v", err)
	}

	if refreshToken == refreshToken2 {
		t.Error("Refresh tokens should be unique")
	}
}

func TestValidateTokenInvalid(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	mockRepo := &MockAuthRepository{}
	authService := service.NewAuthService(mockRepo, cfg)

	_, isValid, _ := authService.ValidateToken("invalid.token.here")
	if isValid {
		t.Error("Invalid token should not be valid")
	}

	_, isValid, _ = authService.ValidateToken("")
	if isValid {
		t.Error("Empty token should not be valid")
	}
}
