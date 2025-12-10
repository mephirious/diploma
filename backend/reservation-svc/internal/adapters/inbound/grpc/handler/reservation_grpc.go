package handler

import (
	"context"
	"time"

	"github.com/diploma/reservation-svc/api/v1"
	"github.com/diploma/reservation-svc/internal/application/reservation/dto"
	"github.com/diploma/reservation-svc/internal/application/reservation/usecase"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type ReservationGRPCHandler struct {
	reservationv1.UnimplementedReservationServiceServer
	createReservationUseCase      *usecase.CreateReservationUseCase
	confirmReservationUseCase      *usecase.ConfirmReservationUseCase
	cancelReservationUseCase       *usecase.CancelReservationUseCase
	getReservationUseCase          *usecase.GetReservationUseCase
	listReservationsByUserUseCase  *usecase.ListReservationsByUserUseCase
}

func NewReservationGRPCHandler(
	createReservationUseCase *usecase.CreateReservationUseCase,
	confirmReservationUseCase *usecase.ConfirmReservationUseCase,
	cancelReservationUseCase *usecase.CancelReservationUseCase,
	getReservationUseCase *usecase.GetReservationUseCase,
	listReservationsByUserUseCase *usecase.ListReservationsByUserUseCase,
) *ReservationGRPCHandler {
	return &ReservationGRPCHandler{
		createReservationUseCase:     createReservationUseCase,
		confirmReservationUseCase:     confirmReservationUseCase,
		cancelReservationUseCase:      cancelReservationUseCase,
		getReservationUseCase:         getReservationUseCase,
		listReservationsByUserUseCase: listReservationsByUserUseCase,
	}
}

func (h *ReservationGRPCHandler) CreateReservation(ctx context.Context, req *reservationv1.CreateReservationRequest) (*reservationv1.CreateReservationResponse, error) {
	if req.UserId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "user_id is required")
	}
	if req.ApartmentId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "apartment_id is required")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid user_id format: %v", err)
	}

	apartmentID, err := uuid.Parse(req.ApartmentId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid apartment_id format: %v", err)
	}

	var comment *string
	if req.Comment != "" {
		comment = &req.Comment
	}

	input := dto.CreateReservationInput{
		UserID:      userID,
		ApartmentID: apartmentID,
		Comment:     comment,
	}

	output, err := h.createReservationUseCase.Execute(ctx, input)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to create reservation: %v", err)
	}

	return &reservationv1.CreateReservationResponse{
		ReservationId: output.ReservationID.String(),
	}, nil
}

func (h *ReservationGRPCHandler) ConfirmReservation(ctx context.Context, req *reservationv1.ConfirmReservationRequest) (*reservationv1.ConfirmReservationResponse, error) {
	if req.ReservationId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "reservation_id is required")
	}

	reservationID, err := uuid.Parse(req.ReservationId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid reservation_id format: %v", err)
	}

	input := dto.ConfirmReservationInput{
		ReservationID: reservationID,
	}

	output, err := h.confirmReservationUseCase.Execute(ctx, input)
	if err != nil {
		if err.Error() == "cannot confirm reservation with status CANCELLED" || err.Error() == "cannot confirm reservation with status CONFIRMED" {
			return nil, status.Errorf(codes.FailedPrecondition, err.Error())
		}
		return nil, status.Errorf(codes.Internal, "failed to confirm reservation: %v", err)
	}

	return &reservationv1.ConfirmReservationResponse{
		Success: output.Success,
	}, nil
}

func (h *ReservationGRPCHandler) CancelReservation(ctx context.Context, req *reservationv1.CancelReservationRequest) (*reservationv1.CancelReservationResponse, error) {
	if req.ReservationId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "reservation_id is required")
	}

	reservationID, err := uuid.Parse(req.ReservationId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid reservation_id format: %v", err)
	}

	input := dto.CancelReservationInput{
		ReservationID: reservationID,
	}

	output, err := h.cancelReservationUseCase.Execute(ctx, input)
	if err != nil {
		if err.Error() == "cannot cancel reservation with status CANCELLED" {
			return nil, status.Errorf(codes.FailedPrecondition, err.Error())
		}
		return nil, status.Errorf(codes.Internal, "failed to cancel reservation: %v", err)
	}

	return &reservationv1.CancelReservationResponse{
		Success: output.Success,
	}, nil
}

func (h *ReservationGRPCHandler) GetReservation(ctx context.Context, req *reservationv1.GetReservationRequest) (*reservationv1.GetReservationResponse, error) {
	if req.ReservationId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "reservation_id is required")
	}

	reservationID, err := uuid.Parse(req.ReservationId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid reservation_id format: %v", err)
	}

	input := dto.GetReservationInput{
		ReservationID: reservationID,
	}

	output, err := h.getReservationUseCase.Execute(ctx, input)
	if err != nil {
		if err.Error() == "reservation not found" {
			return nil, status.Errorf(codes.NotFound, "reservation not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to get reservation: %v", err)
	}

	response := &reservationv1.GetReservationResponse{
		Id:         output.ID.String(),
		UserId:     output.UserID.String(),
		ApartmentId: output.ApartmentID.String(),
		Status:     output.Status,
		ReservedAt: output.ReservedAt.Format(time.RFC3339),
	}

	if output.ExpiresAt != nil {
		response.ExpiresAt = output.ExpiresAt.Format(time.RFC3339)
	}
	if output.Comment != nil {
		response.Comment = *output.Comment
	}

	return response, nil
}

func (h *ReservationGRPCHandler) ListReservationsByUser(ctx context.Context, req *reservationv1.ListReservationsByUserRequest) (*reservationv1.ListReservationsByUserResponse, error) {
	if req.UserId == "" {
		return nil, status.Errorf(codes.InvalidArgument, "user_id is required")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid user_id format: %v", err)
	}

	input := dto.ListReservationsByUserInput{
		UserID: userID,
	}

	output, err := h.listReservationsByUserUseCase.Execute(ctx, input)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list reservations: %v", err)
	}

	items := make([]*reservationv1.GetReservationResponse, 0, len(output.Items))
	for _, item := range output.Items {
		resp := &reservationv1.GetReservationResponse{
			Id:         item.ID.String(),
			UserId:     item.UserID.String(),
			ApartmentId: item.ApartmentID.String(),
			Status:     item.Status,
			ReservedAt: item.ReservedAt.Format(time.RFC3339),
		}

		if item.ExpiresAt != nil {
			resp.ExpiresAt = item.ExpiresAt.Format(time.RFC3339)
		}
		if item.Comment != nil {
			resp.Comment = *item.Comment
		}

		items = append(items, resp)
	}

	return &reservationv1.ListReservationsByUserResponse{
		Items: items,
	}, nil
}

