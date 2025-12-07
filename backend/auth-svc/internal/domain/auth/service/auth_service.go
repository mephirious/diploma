package service

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"time"

	"github.com/diploma/auth-svc/internal/config"
	"github.com/diploma/auth-svc/internal/domain/auth/entity"
	"github.com/diploma/auth-svc/internal/domain/auth/port"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type AuthService struct {
	authRepo port.AuthRepository
	cfg      *config.Config
}

func NewAuthService(authRepo port.AuthRepository, cfg *config.Config) *AuthService {
	return &AuthService{
		authRepo: authRepo,
		cfg:      cfg,
	}
}

type Claims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

func (s *AuthService) HashPassword(password string) (string, error) {

	return "", errors.New("use UserService.CreateUser for password hashing")
}

func (s *AuthService) GenerateToken(userID, email string) (string, error) {
	now := time.Now()
	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.cfg.JWT.AccessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    s.cfg.JWT.Issuer,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.cfg.JWT.Secret))
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	return tokenString, nil
}

func (s *AuthService) GenerateRefreshToken() (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", fmt.Errorf("failed to generate refresh token: %w", err)
	}
	return base64.URLEncoding.EncodeToString(bytes), nil
}

func (s *AuthService) ValidateToken(tokenString string) (string, bool, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.cfg.JWT.Secret), nil
	})

	if err != nil {
		return "", false, fmt.Errorf("failed to parse token: %w", err)
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims.UserID, true, nil
	}

	return "", false, errors.New("invalid token")
}

func (s *AuthService) SaveRefreshToken(ctx context.Context, userID string, refreshToken string) error {

	userUUID, err := uuid.Parse(userID)
	if err != nil {
		return fmt.Errorf("invalid user ID: %w", err)
	}

	token := &entity.Token{
		UserID:       userUUID,
		RefreshToken: refreshToken,
	}

	return s.authRepo.SaveRefreshToken(ctx, token)
}

func (s *AuthService) ValidateRefreshToken(ctx context.Context, refreshToken string) (string, error) {
	token, err := s.authRepo.GetRefreshToken(ctx, refreshToken)
	if err != nil {
		return "", fmt.Errorf("refresh token not found: %w", err)
	}

	if token == nil {
		return "", errors.New("refresh token not found")
	}

	return token.UserID.String(), nil
}
