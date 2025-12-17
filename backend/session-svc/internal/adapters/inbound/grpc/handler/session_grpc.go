package handler

import (
	"context"

	sessionv1 "github.com/diploma/session-svc/api/v1"
	participantusecase "github.com/diploma/session-svc/internal/application/participant/usecase"
	sessionusecase "github.com/diploma/session-svc/internal/application/session/usecase"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type SessionGRPCHandler struct {
	sessionv1.UnimplementedSessionServiceServer
	createSessionUseCase           *sessionusecase.CreateSessionUseCase
	getSessionUseCase              *sessionusecase.GetSessionUseCase
	listOpenSessionsUseCase        *sessionusecase.ListOpenSessionsUseCase
	listUserSessionsUseCase        *sessionusecase.ListUserSessionsUseCase
	cancelSessionUseCase           *sessionusecase.CancelSessionUseCase
	joinSessionUseCase             *participantusecase.JoinSessionUseCase
	leaveSessionUseCase            *participantusecase.LeaveSessionUseCase
	listSessionParticipantsUseCase *participantusecase.ListSessionParticipantsUseCase
}

func NewSessionGRPCHandler(
	createSessionUseCase *sessionusecase.CreateSessionUseCase,
	getSessionUseCase *sessionusecase.GetSessionUseCase,
	listOpenSessionsUseCase *sessionusecase.ListOpenSessionsUseCase,
	listUserSessionsUseCase *sessionusecase.ListUserSessionsUseCase,
	cancelSessionUseCase *sessionusecase.CancelSessionUseCase,
	joinSessionUseCase *participantusecase.JoinSessionUseCase,
	leaveSessionUseCase *participantusecase.LeaveSessionUseCase,
	listSessionParticipantsUseCase *participantusecase.ListSessionParticipantsUseCase,
) *SessionGRPCHandler {
	return &SessionGRPCHandler{
		createSessionUseCase:           createSessionUseCase,
		getSessionUseCase:              getSessionUseCase,
		listOpenSessionsUseCase:        listOpenSessionsUseCase,
		listUserSessionsUseCase:        listUserSessionsUseCase,
		cancelSessionUseCase:           cancelSessionUseCase,
		joinSessionUseCase:             joinSessionUseCase,
		leaveSessionUseCase:            leaveSessionUseCase,
		listSessionParticipantsUseCase: listSessionParticipantsUseCase,
	}
}

func (h *SessionGRPCHandler) CreateSession(ctx context.Context, req *sessionv1.CreateSessionRequest) (*sessionv1.CreateSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) GetSession(ctx context.Context, req *sessionv1.GetSessionRequest) (*sessionv1.GetSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) ListOpenSessions(ctx context.Context, req *sessionv1.ListOpenSessionsRequest) (*sessionv1.ListOpenSessionsResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) ListUserSessions(ctx context.Context, req *sessionv1.ListUserSessionsRequest) (*sessionv1.ListUserSessionsResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) JoinSession(ctx context.Context, req *sessionv1.JoinSessionRequest) (*sessionv1.JoinSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) LeaveSession(ctx context.Context, req *sessionv1.LeaveSessionRequest) (*sessionv1.LeaveSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) CancelSession(ctx context.Context, req *sessionv1.CancelSessionRequest) (*sessionv1.CancelSessionResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *SessionGRPCHandler) ListSessionParticipants(ctx context.Context, req *sessionv1.ListSessionParticipantsRequest) (*sessionv1.ListSessionParticipantsResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

