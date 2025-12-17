package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/diploma/api-gateway/internal/client"
	authv1 "github.com/diploma/api-gateway/api/proto/auth/v1"
)

type contextKey string

const UserIDKey contextKey = "userID"

type AuthMiddleware struct {
	authClient *client.AuthClient
}

func NewAuthMiddleware(authClient *client.AuthClient) *AuthMiddleware {
	return &AuthMiddleware{
		authClient: authClient,
	}
}

func (m *AuthMiddleware) Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, `{"error":"missing authorization header"}`, http.StatusUnauthorized)
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			http.Error(w, `{"error":"invalid authorization header format"}`, http.StatusUnauthorized)
			return
		}

		token := parts[1]

		resp, err := m.authClient.ValidateToken(r.Context(), &authv1.ValidateTokenRequest{
			Token: token,
		})
		if err != nil {
			http.Error(w, `{"error":"invalid token"}`, http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), UserIDKey, resp.UserId)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func GetUserID(ctx context.Context) string {
	if userID, ok := ctx.Value(UserIDKey).(string); ok {
		return userID
	}
	return ""
}

