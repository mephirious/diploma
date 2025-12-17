package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/diploma/auth-svc/internal/application/user/dto"
	"github.com/diploma/auth-svc/internal/application/user/usecase"
	"github.com/diploma/auth-svc/internal/config"
	"github.com/diploma/auth-svc/internal/domain/auth/entity"
	authservice "github.com/diploma/auth-svc/internal/domain/auth/service"
	userentity "github.com/diploma/auth-svc/internal/domain/user/entity"
	userservice "github.com/diploma/auth-svc/internal/domain/user/service"
	pkgerrors "github.com/diploma/auth-svc/pkg/errors"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type MockAuthRepository struct {
	tokens map[string]*entity.Token
}

func NewMockAuthRepository() *MockAuthRepository {
	return &MockAuthRepository{
		tokens: make(map[string]*entity.Token),
	}
}

func (m *MockAuthRepository) SaveRefreshToken(ctx context.Context, token *entity.Token) error {
	m.tokens[token.RefreshToken] = token
	return nil
}

func (m *MockAuthRepository) GetRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error) {
	token, ok := m.tokens[refreshToken]
	if !ok {
		return nil, fmt.Errorf("refresh token not found")
	}
	return token, nil
}

func (m *MockAuthRepository) DeleteRefreshToken(ctx context.Context, refreshToken string) error {
	delete(m.tokens, refreshToken)
	return nil
}

type MockUserRepository struct {
	users       map[uuid.UUID]*userentity.User
	emailIndex  map[string]*userentity.User
	shouldError bool
}

func NewMockUserRepository() *MockUserRepository {
	return &MockUserRepository{
		users:      make(map[uuid.UUID]*userentity.User),
		emailIndex: make(map[string]*userentity.User),
	}
}

func (m *MockUserRepository) Create(ctx context.Context, user *userentity.User) error {
	if m.shouldError {
		return fmt.Errorf("database error")
	}
	
	if _, exists := m.emailIndex[user.Email]; exists {
		return pkgerrors.NewAlreadyExistsError("user with this email already exists")
	}
	
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}
	user.CreatedAt = time.Now()
	
	m.users[user.ID] = user
	m.emailIndex[user.Email] = user
	return nil
}

func (m *MockUserRepository) GetByEmail(ctx context.Context, email string) (*userentity.User, error) {
	if m.shouldError {
		return nil, fmt.Errorf("database error")
	}
	
	user, ok := m.emailIndex[email]
	if !ok {
		return nil, pkgerrors.NewNotFoundError("user not found")
	}
	return user, nil
}

func (m *MockUserRepository) GetByID(ctx context.Context, id string) (*userentity.User, error) {
	if m.shouldError {
		return nil, fmt.Errorf("database error")
	}
	
	userID, err := uuid.Parse(id)
	if err != nil {
		return nil, pkgerrors.NewInvalidArgumentError("invalid user ID")
	}
	
	user, ok := m.users[userID]
	if !ok {
		return nil, pkgerrors.NewNotFoundError("user not found")
	}
	return user, nil
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

	mockRepo := NewMockAuthRepository()
	authService := authservice.NewAuthService(mockRepo, cfg)

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

	mockRepo := NewMockAuthRepository()
	authService := authservice.NewAuthService(mockRepo, cfg)

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

	mockRepo := NewMockAuthRepository()
	authService := authservice.NewAuthService(mockRepo, cfg)

	_, isValid, _ := authService.ValidateToken("invalid.token.here")
	if isValid {
		t.Error("Invalid token should not be valid")
	}

	_, isValid, _ = authService.ValidateToken("")
	if isValid {
		t.Error("Empty token should not be valid")
	}
}

func TestRegisterUserSuccess(t *testing.T) {
	userRepo := NewMockUserRepository()
	userSvc := userservice.NewUserService(userRepo)
	registerUseCase := usecase.NewRegisterUserUseCase(userSvc)

	input := dto.RegisterUserInput{
		FullName: "John Doe",
		Email:    "john@example.com",
		Phone:    "+1234567890",
		Password: "secure_password",
	}

	output, err := registerUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("Failed to register user: %v", err)
	}

	if output.UserID == "" {
		t.Error("Expected user ID to be set")
	}

	user, err := userRepo.GetByEmail(context.Background(), input.Email)
	if err != nil {
		t.Fatalf("Failed to retrieve user: %v", err)
	}

	if user.Email != input.Email {
		t.Errorf("Expected email %s, got %s", input.Email, user.Email)
	}
	if user.FullName != input.FullName {
		t.Errorf("Expected full name %s, got %s", input.FullName, user.FullName)
	}
}

func TestRegisterUserDuplicateEmail(t *testing.T) {
	userRepo := NewMockUserRepository()
	userSvc := userservice.NewUserService(userRepo)
	registerUseCase := usecase.NewRegisterUserUseCase(userSvc)

	input := dto.RegisterUserInput{
		FullName: "John Doe",
		Email:    "john@example.com",
		Phone:    "+1234567890",
		Password: "secure_password",
	}

	_, err := registerUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("First registration should succeed: %v", err)
	}

	_, err = registerUseCase.Execute(context.Background(), input)
	if err == nil {
		t.Error("Expected error for duplicate email")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeAlreadyExists {
		t.Errorf("Expected AlreadyExists error, got %s", pkgerrors.GetErrorCode(err))
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeAlreadyExists {
		t.Errorf("Expected AlreadyExists error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestRegisterUserInvalidInput(t *testing.T) {
	userRepo := NewMockUserRepository()
	userSvc := userservice.NewUserService(userRepo)
	registerUseCase := usecase.NewRegisterUserUseCase(userSvc)

	tests := []struct {
		name  string
		input dto.RegisterUserInput
	}{
		{
			name: "empty email",
			input: dto.RegisterUserInput{
				FullName: "John Doe",
				Email:    "",
				Password: "secure_password",
			},
		},
		{
			name: "empty password",
			input: dto.RegisterUserInput{
				FullName: "John Doe",
				Email:    "john@example.com",
				Password: "",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := registerUseCase.Execute(context.Background(), tt.input)
			if err == nil {
				t.Error("Expected validation error")
			}

			if pkgerrors.GetErrorCode(err) != pkgerrors.CodeInvalidArgument {
				t.Errorf("Expected InvalidArgument error, got %s", pkgerrors.GetErrorCode(err))
			}
		})
	}
}

func TestLoginUserSuccess(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	userRepo := NewMockUserRepository()
	authRepo := NewMockAuthRepository()
	
	userSvc := userservice.NewUserService(userRepo)
	authSvc := authservice.NewAuthService(authRepo, cfg)
	
	loginUseCase := usecase.NewLoginUserUseCase(userSvc, authSvc)

	password := "secure_password"
	user, err := userSvc.CreateUser(context.Background(), "John Doe", "john@example.com", "+1234567890", password)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	input := dto.LoginUserInput{
		Email:    user.Email,
		Password: password,
	}

	output, err := loginUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("Failed to login: %v", err)
	}

	if output.AccessToken == "" {
		t.Error("Expected access token to be set")
	}
	if output.RefreshToken == "" {
		t.Error("Expected refresh token to be set")
	}

	userID, isValid, err := authSvc.ValidateToken(output.AccessToken)
	if err != nil {
		t.Errorf("Failed to validate token: %v", err)
	}
	if !isValid {
		t.Error("Token should be valid")
	}
	if userID != user.ID.String() {
		t.Errorf("Expected user ID %s, got %s", user.ID.String(), userID)
	}
}

func TestLoginUserInvalidPassword(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	userRepo := NewMockUserRepository()
	authRepo := NewMockAuthRepository()
	
	userSvc := userservice.NewUserService(userRepo)
	authSvc := authservice.NewAuthService(authRepo, cfg)
	
	loginUseCase := usecase.NewLoginUserUseCase(userSvc, authSvc)

	password := "secure_password"
	user, err := userSvc.CreateUser(context.Background(), "John Doe", "john@example.com", "+1234567890", password)
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	input := dto.LoginUserInput{
		Email:    user.Email,
		Password: "wrong_password",
	}

	_, err = loginUseCase.Execute(context.Background(), input)
	if err == nil {
		t.Error("Expected authentication error for wrong password")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeUnauthenticated {
		t.Errorf("Expected Unauthenticated error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestLoginUserNotFound(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	userRepo := NewMockUserRepository()
	authRepo := NewMockAuthRepository()
	
	userSvc := userservice.NewUserService(userRepo)
	authSvc := authservice.NewAuthService(authRepo, cfg)
	
	loginUseCase := usecase.NewLoginUserUseCase(userSvc, authSvc)

	input := dto.LoginUserInput{
		Email:    "nonexistent@example.com",
		Password: "some_password",
	}

	_, err := loginUseCase.Execute(context.Background(), input)
	if err == nil {
		t.Error("Expected authentication error for non-existent user")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeUnauthenticated {
		t.Errorf("Expected Unauthenticated error, got %s", pkgerrors.GetErrorCode(err))
	}
}

func TestGetUserProfileSuccess(t *testing.T) {
	userRepo := NewMockUserRepository()
	userSvc := userservice.NewUserService(userRepo)
	getUserProfileUseCase := usecase.NewGetUserProfileUseCase(userSvc)

	user, err := userSvc.CreateUser(context.Background(), "John Doe", "john@example.com", "+1234567890", "password")
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	input := dto.GetUserProfileInput{
		UserID: user.ID.String(),
	}

	output, err := getUserProfileUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("Failed to get user profile: %v", err)
	}

	if output.User.ID != user.ID.String() {
		t.Errorf("Expected user ID %s, got %s", user.ID.String(), output.User.ID)
	}
	if output.User.Email != user.Email {
		t.Errorf("Expected email %s, got %s", user.Email, output.User.Email)
	}
}

func TestGetUserProfileNotFound(t *testing.T) {
	userRepo := NewMockUserRepository()
	userSvc := userservice.NewUserService(userRepo)
	getUserProfileUseCase := usecase.NewGetUserProfileUseCase(userSvc)

	input := dto.GetUserProfileInput{
		UserID: uuid.New().String(),
	}

	_, err := getUserProfileUseCase.Execute(context.Background(), input)
	if err == nil {
		t.Error("Expected error for non-existent user")
	}
}

func TestRefreshTokenSuccess(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	userRepo := NewMockUserRepository()
	authRepo := NewMockAuthRepository()
	
	userSvc := userservice.NewUserService(userRepo)
	authSvc := authservice.NewAuthService(authRepo, cfg)
	
	refreshTokenUseCase := usecase.NewRefreshTokenUseCase(authSvc, userSvc)

	user, err := userSvc.CreateUser(context.Background(), "John Doe", "john@example.com", "+1234567890", "password")
	if err != nil {
		t.Fatalf("Failed to create user: %v", err)
	}

	oldRefreshToken, err := authSvc.GenerateRefreshToken()
	if err != nil {
		t.Fatalf("Failed to generate refresh token: %v", err)
	}

	err = authSvc.SaveRefreshToken(context.Background(), user.ID.String(), oldRefreshToken)
	if err != nil {
		t.Fatalf("Failed to save refresh token: %v", err)
	}

	input := dto.RefreshTokenInput{
		RefreshToken: oldRefreshToken,
	}

	output, err := refreshTokenUseCase.Execute(context.Background(), input)
	if err != nil {
		t.Fatalf("Failed to refresh token: %v", err)
	}

	if output.AccessToken == "" {
		t.Error("Expected new access token")
	}
	if output.RefreshToken == "" {
		t.Error("Expected new refresh token")
	}
	if output.RefreshToken == oldRefreshToken {
		t.Error("Expected new refresh token to be different from old one")
	}
}

func TestRefreshTokenInvalid(t *testing.T) {
	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:          "test_secret_key_min_32_chars_long_for_hmac",
			AccessTokenTTL:  15 * time.Minute,
			RefreshTokenTTL: 7 * 24 * time.Hour,
			Issuer:          "auth-svc-test",
		},
	}

	userRepo := NewMockUserRepository()
	authRepo := NewMockAuthRepository()
	
	userSvc := userservice.NewUserService(userRepo)
	authSvc := authservice.NewAuthService(authRepo, cfg)
	
	refreshTokenUseCase := usecase.NewRefreshTokenUseCase(authSvc, userSvc)

	input := dto.RefreshTokenInput{
		RefreshToken: "invalid_token",
	}

	_, err := refreshTokenUseCase.Execute(context.Background(), input)
	if err == nil {
		t.Error("Expected error for invalid refresh token")
	}

	if pkgerrors.GetErrorCode(err) != pkgerrors.CodeUnauthenticated {
		t.Errorf("Expected Unauthenticated error, got %s", pkgerrors.GetErrorCode(err))
	}
}
