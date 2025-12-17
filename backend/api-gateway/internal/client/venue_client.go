package client

import (
	"context"

	venuev1 "github.com/diploma/api-gateway/api/proto/venue/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type VenueClient struct {
	client venuev1.VenueServiceClient
	conn   *grpc.ClientConn
}

func NewVenueClient(address string) (*VenueClient, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return &VenueClient{
		client: venuev1.NewVenueServiceClient(conn),
		conn:   conn,
	}, nil
}

func (c *VenueClient) Close() error {
	return c.conn.Close()
}

func (c *VenueClient) ListVenues(ctx context.Context, req *venuev1.ListVenuesRequest) (*venuev1.ListVenuesResponse, error) {
	return c.client.ListVenues(ctx, req)
}

func (c *VenueClient) GetVenue(ctx context.Context, req *venuev1.GetVenueRequest) (*venuev1.GetVenueResponse, error) {
	return c.client.GetVenue(ctx, req)
}

func (c *VenueClient) ListResourcesByVenue(ctx context.Context, req *venuev1.ListResourcesByVenueRequest) (*venuev1.ListResourcesByVenueResponse, error) {
	return c.client.ListResourcesByVenue(ctx, req)
}

