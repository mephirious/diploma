package handler

import (
	"context"

	authv1 "github.com/diploma/auth-svc/api/v1"
	"github.com/diploma/auth-svc/internal/application/user/dto"
	"github.com/diploma/auth-svc/internal/application/user/usecase"
	pkgerrors "github.com/diploma/auth-svc/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type UserGRPCHandler struct {
	authv1.UnimplementedAuthServiceServer
	registerUserUseCase    *usecase.RegisterUserUseCase
	getUserProfileUseCase *usecase.GetUserProfileUseCase
}

func NewUserGRPCHandler(
	registerUserUseCase *usecase.RegisterUserUseCase,
	getUserProfileUseCase *usecase.GetUserProfileUseCase,
) *UserGRPCHandler {
	return &UserGRPCHandler{
		registerUserUseCase:    registerUserUseCase,
		getUserProfileUseCase: getUserProfileUseCase,
	}
}

func (h *UserGRPCHandler) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterResponse, error) {
	if req.Email == "" {
		return nil, status.Errorf(codes.InvalidArgument, "email is required")
	}
	if req.Password == "" {
		return nil, status.Errorf(codes.InvalidArgument, "password is required")
	}

	input := dto.RegisterUserInput{
		FullName: req.FullName,
		Email:    req.Email,
		Phone:    req.Phone,
		Password: req.Password,
	}

	output, err := h.registerUserUseCase.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &authv1.RegisterResponse{
		UserId: output.UserID,
	}, nil
}

func (h *UserGRPCHandler) GetUserProfile(ctx context.Context, req *authv1.GetUserProfileRequest) (*authv1.GetUserProfileResponse, error) {
	if req.UserId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "user_id is required")
	}

	input := dto.GetUserProfileInput{
		UserID: req.UserId,
	}

	output, err := h.getUserProfileUseCase.Execute(ctx, input)
	if err != nil {
		return nil, mapErrorToGRPCStatus(err)
	}

	return &authv1.GetUserProfileResponse{
		UserId:    output.User.ID,
		FullName:  output.User.FullName,
		Email:     output.User.Email,
		Phone:     output.User.Phone,
		CreatedAt: output.User.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}, nil
}

func mapErrorToGRPCStatus(err error) error {
	if err == nil {
		return nil
	}

	if pkgerrors.IsDomainError(err) {
		code := pkgerrors.GetErrorCode(err)
		msg := err.Error()

		switch code {
		case pkgerrors.CodeNotFound:
			return status.Errorf(codes.NotFound, msg)
		case pkgerrors.CodeAlreadyExists:
			return status.Errorf(codes.AlreadyExists, msg)
		case pkgerrors.CodeInvalidArgument:
			return status.Errorf(codes.InvalidArgument, msg)
		case pkgerrors.CodeUnauthenticated:
			return status.Errorf(codes.Unauthenticated, msg)
		case pkgerrors.CodePermissionDenied:
			return status.Errorf(codes.PermissionDenied, msg)
		default:
			return status.Errorf(codes.Internal, "internal server error")
		}
	}

	return status.Errorf(codes.Internal, "internal server error")
}
