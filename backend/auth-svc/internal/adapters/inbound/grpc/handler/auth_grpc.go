package handler

import (
	"context"

	authv1 "github.com/diploma/auth-svc/api/v1"
	"github.com/diploma/auth-svc/internal/application/user/dto"
	"github.com/diploma/auth-svc/internal/application/user/usecase"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type AuthGRPCHandler struct {
	authv1.UnimplementedAuthServiceServer
	loginUserUseCase    *usecase.LoginUserUseCase
	refreshTokenUseCase *usecase.RefreshTokenUseCase
	authService         TokenValidator
}

type TokenValidator interface {
	ValidateToken(tokenString string) (userID string, isValid bool, err error)
}

func NewAuthGRPCHandler(
	loginUserUseCase *usecase.LoginUserUseCase,
	refreshTokenUseCase *usecase.RefreshTokenUseCase,
	authService TokenValidator,
) *AuthGRPCHandler {
	return &AuthGRPCHandler{
		loginUserUseCase:    loginUserUseCase,
		refreshTokenUseCase: refreshTokenUseCase,
		authService:         authService,
	}
}

func (h *AuthGRPCHandler) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginResponse, error) {
	if req.Email == "" {
		return nil, status.Errorf(codes.InvalidArgument, "email is required")
	}
	if req.Password == "" {
		return nil, status.Errorf(codes.InvalidArgument, "password is required")
	}

	input := dto.LoginUserInput{
		Email:    req.Email,
		Password: req.Password,
	}

	output, err := h.loginUserUseCase.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &authv1.LoginResponse{
		AccessToken:  output.AccessToken,
		RefreshToken: output.RefreshToken,
		UserId:       output.UserID,
	}, nil
}

func (h *AuthGRPCHandler) ValidateToken(ctx context.Context, req *authv1.ValidateTokenRequest) (*authv1.ValidateTokenResponse, error) {
	if req.Token == "" {
		return nil, status.Errorf(codes.InvalidArgument, "token is required")
	}

	userID, isValid, err := h.authService.ValidateToken(req.Token)
	if err != nil {
		return &authv1.ValidateTokenResponse{
			UserId:  "",
			IsValid: false,
		}, nil
	}

	return &authv1.ValidateTokenResponse{
		UserId:  userID,
		IsValid: isValid,
	}, nil
}

func (h *AuthGRPCHandler) RefreshToken(ctx context.Context, req *authv1.RefreshTokenRequest) (*authv1.RefreshTokenResponse, error) {
	if req.RefreshToken == "" {
		return nil, status.Errorf(codes.InvalidArgument, "refresh_token is required")
	}

	input := dto.RefreshTokenInput{
		RefreshToken: req.RefreshToken,
	}

	output, err := h.refreshTokenUseCase.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &authv1.RefreshTokenResponse{
		AccessToken:  output.AccessToken,
		RefreshToken: output.RefreshToken,
	}, nil
}
