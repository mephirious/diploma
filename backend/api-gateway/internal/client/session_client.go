package client

import (
	"context"

	sessionv1 "github.com/diploma/api-gateway/api/proto/session/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type SessionClient struct {
	client sessionv1.SessionServiceClient
	conn   *grpc.ClientConn
}

func NewSessionClient(address string) (*SessionClient, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return &SessionClient{
		client: sessionv1.NewSessionServiceClient(conn),
		conn:   conn,
	}, nil
}

func (c *SessionClient) Close() error {
	return c.conn.Close()
}

func (c *SessionClient) CreateSession(ctx context.Context, req *sessionv1.CreateSessionRequest) (*sessionv1.CreateSessionResponse, error) {
	return c.client.CreateSession(ctx, req)
}

func (c *SessionClient) GetSession(ctx context.Context, req *sessionv1.GetSessionRequest) (*sessionv1.GetSessionResponse, error) {
	return c.client.GetSession(ctx, req)
}

func (c *SessionClient) ListOpenSessions(ctx context.Context, req *sessionv1.ListOpenSessionsRequest) (*sessionv1.ListOpenSessionsResponse, error) {
	return c.client.ListOpenSessions(ctx, req)
}

func (c *SessionClient) JoinSession(ctx context.Context, req *sessionv1.JoinSessionRequest) (*sessionv1.JoinSessionResponse, error) {
	return c.client.JoinSession(ctx, req)
}

func (c *SessionClient) CancelSession(ctx context.Context, req *sessionv1.CancelSessionRequest) (*sessionv1.CancelSessionResponse, error) {
	return c.client.CancelSession(ctx, req)
}

