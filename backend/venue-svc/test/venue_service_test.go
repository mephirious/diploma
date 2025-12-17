package test

import (
	"context"
	"testing"

	"github.com/diploma/venue-svc/internal/domain/venue/entity"
	"github.com/diploma/venue-svc/internal/domain/venue/service"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type MockVenueRepository struct {
	venues      map[uuid.UUID]*entity.Venue
	shouldError bool
}

func NewMockVenueRepository() *MockVenueRepository {
	return &MockVenueRepository{
		venues: make(map[uuid.UUID]*entity.Venue),
	}
}

func (m *MockVenueRepository) Create(ctx context.Context, venue *entity.Venue) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	m.venues[venue.ID] = venue
	return nil
}

func (m *MockVenueRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.Venue, error) {
	if m.shouldError {
		return nil, pkgerrors.NewInternalError("mock error", nil)
	}
	venue, exists := m.venues[id]
	if !exists {
		return nil, pkgerrors.NewNotFoundError("venue not found")
	}
	return venue, nil
}

func (m *MockVenueRepository) List(ctx context.Context, city string, offset, limit int) ([]*entity.Venue, int, error) {
	if m.shouldError {
		return nil, 0, pkgerrors.NewInternalError("mock error", nil)
	}

	result := []*entity.Venue{}
	for _, venue := range m.venues {
		if city == "" || venue.City == city {
			result = append(result, venue)
		}
	}
	return result, len(result), nil
}

func (m *MockVenueRepository) Update(ctx context.Context, venue *entity.Venue) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	if _, exists := m.venues[venue.ID]; !exists {
		return pkgerrors.NewNotFoundError("venue not found")
	}
	m.venues[venue.ID] = venue
	return nil
}

func (m *MockVenueRepository) Delete(ctx context.Context, id uuid.UUID) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	if _, exists := m.venues[id]; !exists {
		return pkgerrors.NewNotFoundError("venue not found")
	}
	delete(m.venues, id)
	return nil
}

func TestVenueService_CreateVenue_Success(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	ownerID := uuid.New()
	venue, err := svc.CreateVenue(
		context.Background(),
		ownerID,
		"Test Venue",
		"A test venue",
		"New York",
		"123 Main St",
		40.7128,
		-74.0060,
	)

	require.NoError(t, err)
	assert.NotNil(t, venue)
	assert.Equal(t, "Test Venue", venue.Name)
	assert.Equal(t, "New York", venue.City)
	assert.Equal(t, ownerID, venue.OwnerID)
}

func TestVenueService_CreateVenue_InvalidInput(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	tests := []struct {
		name        string
		ownerID     uuid.UUID
		venueName   string
		city        string
		address     string
		expectError bool
	}{
		{
			name:        "missing owner_id",
			ownerID:     uuid.Nil,
			venueName:   "Test Venue",
			city:        "New York",
			address:     "123 Main St",
			expectError: true,
		},
		{
			name:        "missing name",
			ownerID:     uuid.New(),
			venueName:   "",
			city:        "New York",
			address:     "123 Main St",
			expectError: true,
		},
		{
			name:        "missing city",
			ownerID:     uuid.New(),
			venueName:   "Test Venue",
			city:        "",
			address:     "123 Main St",
			expectError: true,
		},
		{
			name:        "missing address",
			ownerID:     uuid.New(),
			venueName:   "Test Venue",
			city:        "New York",
			address:     "",
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := svc.CreateVenue(
				context.Background(),
				tt.ownerID,
				tt.venueName,
				"Description",
				tt.city,
				tt.address,
				40.7128,
				-74.0060,
			)

			if tt.expectError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestVenueService_GetVenue_Success(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	ownerID := uuid.New()
	created, err := svc.CreateVenue(
		context.Background(),
		ownerID,
		"Test Venue",
		"A test venue",
		"New York",
		"123 Main St",
		40.7128,
		-74.0060,
	)
	require.NoError(t, err)

	venue, err := svc.GetVenue(context.Background(), created.ID)

	require.NoError(t, err)
	assert.NotNil(t, venue)
	assert.Equal(t, created.ID, venue.ID)
	assert.Equal(t, "Test Venue", venue.Name)
}

func TestVenueService_GetVenue_NotFound(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	nonExistentID := uuid.New()
	_, err := svc.GetVenue(context.Background(), nonExistentID)

	assert.Error(t, err)
	domainErr, ok := err.(*pkgerrors.DomainError)
	require.True(t, ok)
	assert.Equal(t, pkgerrors.CodeNotFound, domainErr.Code)
}

func TestVenueService_ListVenues_Success(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	ownerID := uuid.New()
	_, err := svc.CreateVenue(context.Background(), ownerID, "Venue 1", "Desc 1", "New York", "Addr 1", 40.7128, -74.0060)
	require.NoError(t, err)
	_, err = svc.CreateVenue(context.Background(), ownerID, "Venue 2", "Desc 2", "New York", "Addr 2", 40.7128, -74.0060)
	require.NoError(t, err)
	_, err = svc.CreateVenue(context.Background(), ownerID, "Venue 3", "Desc 3", "Boston", "Addr 3", 42.3601, -71.0589)
	require.NoError(t, err)

	venues, count, err := svc.ListVenues(context.Background(), "", 1, 10)
	require.NoError(t, err)
	assert.Equal(t, 3, count)
	assert.Len(t, venues, 3)

	nyVenues, nyCount, err := svc.ListVenues(context.Background(), "New York", 1, 10)
	require.NoError(t, err)
	assert.Equal(t, 2, nyCount)
	assert.Len(t, nyVenues, 2)
}

func TestVenueService_UpdateVenue_Success(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	ownerID := uuid.New()
	created, err := svc.CreateVenue(
		context.Background(),
		ownerID,
		"Test Venue",
		"Original description",
		"New York",
		"123 Main St",
		40.7128,
		-74.0060,
	)
	require.NoError(t, err)

	updated, err := svc.UpdateVenue(
		context.Background(),
		created.ID,
		"Updated Venue",
		"Updated description",
		"Boston",
		"456 New St",
		42.3601,
		-71.0589,
	)

	require.NoError(t, err)
	assert.Equal(t, "Updated Venue", updated.Name)
	assert.Equal(t, "Boston", updated.City)
}

func TestVenueService_DeleteVenue_Success(t *testing.T) {
	repo := NewMockVenueRepository()
	svc := service.NewVenueService(repo)

	ownerID := uuid.New()
	created, err := svc.CreateVenue(
		context.Background(),
		ownerID,
		"Test Venue",
		"A test venue",
		"New York",
		"123 Main St",
		40.7128,
		-74.0060,
	)
	require.NoError(t, err)

	err = svc.DeleteVenue(context.Background(), created.ID)
	require.NoError(t, err)

	_, err = svc.GetVenue(context.Background(), created.ID)
	assert.Error(t, err)
}

