package handler

import (
	"context"

	authv1 "github.com/diploma/auth-svc/api/v1"
	"github.com/diploma/auth-svc/internal/application/user/usecase"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type UserGRPCHandler struct {
	authv1.UnimplementedAuthServiceServer
	registerUserUseCase *usecase.RegisterUserUseCase
}

func NewUserGRPCHandler(registerUserUseCase *usecase.RegisterUserUseCase) *UserGRPCHandler {
	return &UserGRPCHandler{
		registerUserUseCase: registerUserUseCase,
	}
}

func (h *UserGRPCHandler) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterResponse, error) {

	if req.Email == "" {
		return nil, status.Errorf(codes.InvalidArgument, "email is required")
	}
	if req.Password == "" {
		return nil, status.Errorf(codes.InvalidArgument, "password is required")
	}

	input := usecase.RegisterUserInput{
		FullName: req.FullName,
		Email:    req.Email,
		Phone:    req.Phone,
		Password: req.Password,
	}

	output, err := h.registerUserUseCase.Execute(ctx, input)
	if err != nil {

		if err.Error() == "user with this email already exists" {
			return nil, status.Errorf(codes.AlreadyExists, err.Error())
		}
		return nil, status.Errorf(codes.Internal, "failed to register user: %v", err)
	}

	return &authv1.RegisterResponse{
		UserId: output.UserID,
	}, nil
}
