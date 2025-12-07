package handler

import (
	"context"

	authv1 "github.com/diploma/auth-svc/api/v1"
	"google.golang.org/grpc"
)

type CombinedAuthService struct {
	authv1.UnimplementedAuthServiceServer
	userHandler *UserGRPCHandler
	authHandler *AuthGRPCHandler
}

func NewCombinedAuthService(userHandler *UserGRPCHandler, authHandler *AuthGRPCHandler) *CombinedAuthService {
	return &CombinedAuthService{
		userHandler: userHandler,
		authHandler: authHandler,
	}
}

func (s *CombinedAuthService) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterResponse, error) {
	return s.userHandler.Register(ctx, req)
}

func (s *CombinedAuthService) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginResponse, error) {
	return s.authHandler.Login(ctx, req)
}

func (s *CombinedAuthService) ValidateToken(ctx context.Context, req *authv1.ValidateTokenRequest) (*authv1.ValidateTokenResponse, error) {
	return s.authHandler.ValidateToken(ctx, req)
}

func RegisterAuthService(server *grpc.Server, userHandler *UserGRPCHandler, authHandler *AuthGRPCHandler) {
	combinedService := NewCombinedAuthService(userHandler, authHandler)
	authv1.RegisterAuthServiceServer(server, combinedService)
}
