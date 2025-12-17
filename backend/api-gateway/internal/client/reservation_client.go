package client

import (
	"context"

	reservationv1 "github.com/diploma/api-gateway/api/proto/reservation/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type ReservationClient struct {
	client reservationv1.ReservationServiceClient
	conn   *grpc.ClientConn
}

func NewReservationClient(address string) (*ReservationClient, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return &ReservationClient{
		client: reservationv1.NewReservationServiceClient(conn),
		conn:   conn,
	}, nil
}

func (c *ReservationClient) Close() error {
	return c.conn.Close()
}

func (c *ReservationClient) CreateReservation(ctx context.Context, req *reservationv1.CreateReservationRequest) (*reservationv1.CreateReservationResponse, error) {
	return c.client.CreateReservation(ctx, req)
}

func (c *ReservationClient) GetReservation(ctx context.Context, req *reservationv1.GetReservationRequest) (*reservationv1.GetReservationResponse, error) {
	return c.client.GetReservation(ctx, req)
}

func (c *ReservationClient) ListReservationsByUser(ctx context.Context, req *reservationv1.ListReservationsByUserRequest) (*reservationv1.ListReservationsByUserResponse, error) {
	return c.client.ListReservationsByUser(ctx, req)
}

func (c *ReservationClient) ConfirmReservation(ctx context.Context, req *reservationv1.ConfirmReservationRequest) (*reservationv1.ConfirmReservationResponse, error) {
	return c.client.ConfirmReservation(ctx, req)
}

func (c *ReservationClient) CancelReservation(ctx context.Context, req *reservationv1.CancelReservationRequest) (*reservationv1.CancelReservationResponse, error) {
	return c.client.CancelReservation(ctx, req)
}

