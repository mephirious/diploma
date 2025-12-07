package middleware

import (
	"context"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type AuthInterceptor struct {
	tokenValidator TokenValidator
}

type TokenValidator interface {
	ValidateToken(tokenString string) (userID string, isValid bool, err error)
}

func NewAuthInterceptor(tokenValidator TokenValidator) *AuthInterceptor {
	return &AuthInterceptor{
		tokenValidator: tokenValidator,
	}
}

func (a *AuthInterceptor) UnaryInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {

		if info.FullMethod == "/auth.v1.AuthService/Register" ||
			info.FullMethod == "/auth.v1.AuthService/Login" {
			return handler(ctx, req)
		}

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return nil, status.Errorf(codes.Unauthenticated, "metadata not found")
		}

		authHeaders := md.Get("authorization")
		if len(authHeaders) == 0 {
			return nil, status.Errorf(codes.Unauthenticated, "authorization token not provided")
		}

		authHeader := authHeaders[0]
		const bearerPrefix = "Bearer "
		if !strings.HasPrefix(authHeader, bearerPrefix) {
			return nil, status.Errorf(codes.Unauthenticated, "invalid authorization header format")
		}

		token := strings.TrimPrefix(authHeader, bearerPrefix)

		userID, isValid, err := a.tokenValidator.ValidateToken(token)
		if err != nil || !isValid {
			return nil, status.Errorf(codes.Unauthenticated, "invalid or expired token")
		}

		ctx = context.WithValue(ctx, "user_id", userID)

		return handler(ctx, req)
	}
}
