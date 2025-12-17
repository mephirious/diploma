package client

import (
	"context"

	authv1 "github.com/diploma/api-gateway/api/proto/auth/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type AuthClient struct {
	client authv1.AuthServiceClient
	conn   *grpc.ClientConn
}

func NewAuthClient(address string) (*AuthClient, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return &AuthClient{
		client: authv1.NewAuthServiceClient(conn),
		conn:   conn,
	}, nil
}

func (c *AuthClient) Close() error {
	return c.conn.Close()
}

func (c *AuthClient) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterResponse, error) {
	return c.client.Register(ctx, req)
}

func (c *AuthClient) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginResponse, error) {
	return c.client.Login(ctx, req)
}

func (c *AuthClient) ValidateToken(ctx context.Context, req *authv1.ValidateTokenRequest) (*authv1.ValidateTokenResponse, error) {
	return c.client.ValidateToken(ctx, req)
}

func (c *AuthClient) GetUserProfile(ctx context.Context, req *authv1.GetUserProfileRequest) (*authv1.GetUserProfileResponse, error) {
	return c.client.GetUserProfile(ctx, req)
}

