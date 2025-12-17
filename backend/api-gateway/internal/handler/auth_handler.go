package handler

import (
	"encoding/json"
	"net/http"

	authv1 "github.com/diploma/api-gateway/api/proto/auth/v1"
	"github.com/diploma/api-gateway/internal/client"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type AuthHandler struct {
	authClient *client.AuthClient
}

func NewAuthHandler(authClient *client.AuthClient) *AuthHandler {
	return &AuthHandler{
		authClient: authClient,
	}
}

type RegisterRequest struct {
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Password string `json:"password"`
}

type RegisterResponse struct {
	UserID string `json:"user_id"`
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	resp, err := h.authClient.Register(r.Context(), &authv1.RegisterRequest{
		FullName: req.FullName,
		Email:    req.Email,
		Phone:    req.Phone,
		Password: req.Password,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, RegisterResponse{UserID: resp.UserId})
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	UserID       string `json:"user_id"`
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	resp, err := h.authClient.Login(r.Context(), &authv1.LoginRequest{
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, LoginResponse{
		AccessToken:  resp.AccessToken,
		RefreshToken: resp.RefreshToken,
		UserID:       resp.UserId,
	})
}

type UserProfileResponse struct {
	UserID    string `json:"user_id"`
	FullName  string `json:"full_name"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	CreatedAt string `json:"created_at"`
}

func (h *AuthHandler) GetProfile(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)

	resp, err := h.authClient.GetUserProfile(r.Context(), &authv1.GetUserProfileRequest{
		UserId: userID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, UserProfileResponse{
		UserID:    resp.UserId,
		FullName:  resp.FullName,
		Email:     resp.Email,
		Phone:     resp.Phone,
		CreatedAt: resp.CreatedAt,
	})
}

func writeJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(data)
}

func writeGRPCError(w http.ResponseWriter, err error) {
	st, ok := status.FromError(err)
	if !ok {
		http.Error(w, `{"error":"internal server error"}`, http.StatusInternalServerError)
		return
	}

	var statusCode int
	switch st.Code() {
	case codes.NotFound:
		statusCode = http.StatusNotFound
	case codes.AlreadyExists:
		statusCode = http.StatusConflict
	case codes.InvalidArgument:
		statusCode = http.StatusBadRequest
	case codes.Unauthenticated:
		statusCode = http.StatusUnauthorized
	case codes.PermissionDenied:
		statusCode = http.StatusForbidden
	case codes.FailedPrecondition:
		statusCode = http.StatusPreconditionFailed
	case codes.ResourceExhausted:
		statusCode = http.StatusTooManyRequests
	default:
		statusCode = http.StatusInternalServerError
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(map[string]string{"error": st.Message()})
}

