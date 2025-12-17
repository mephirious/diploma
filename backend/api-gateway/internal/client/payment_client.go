package client

import (
	"context"

	paymentv1 "github.com/diploma/api-gateway/api/proto/payment/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type PaymentClient struct {
	client paymentv1.PaymentServiceClient
	conn   *grpc.ClientConn
}

func NewPaymentClient(address string) (*PaymentClient, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return &PaymentClient{
		client: paymentv1.NewPaymentServiceClient(conn),
		conn:   conn,
	}, nil
}

func (c *PaymentClient) Close() error {
	return c.conn.Close()
}

func (c *PaymentClient) StartPaymentForSession(ctx context.Context, req *paymentv1.StartPaymentForSessionRequest) (*paymentv1.StartPaymentForSessionResponse, error) {
	return c.client.StartPaymentForSession(ctx, req)
}

func (c *PaymentClient) GetPayment(ctx context.Context, req *paymentv1.GetPaymentRequest) (*paymentv1.GetPaymentResponse, error) {
	return c.client.GetPayment(ctx, req)
}

func (c *PaymentClient) GetPaymentsBySession(ctx context.Context, req *paymentv1.GetPaymentsBySessionRequest) (*paymentv1.GetPaymentsBySessionResponse, error) {
	return c.client.GetPaymentsBySession(ctx, req)
}

