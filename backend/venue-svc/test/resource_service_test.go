package test

import (
	"context"
	"testing"

	"github.com/diploma/venue-svc/internal/domain/resource/entity"
	"github.com/diploma/venue-svc/internal/domain/resource/service"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type MockResourceRepository struct {
	resources   map[uuid.UUID]*entity.Resource
	shouldError bool
}

func NewMockResourceRepository() *MockResourceRepository {
	return &MockResourceRepository{
		resources: make(map[uuid.UUID]*entity.Resource),
	}
}

func (m *MockResourceRepository) Create(ctx context.Context, resource *entity.Resource) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	m.resources[resource.ID] = resource
	return nil
}

func (m *MockResourceRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.Resource, error) {
	if m.shouldError {
		return nil, pkgerrors.NewInternalError("mock error", nil)
	}
	resource, exists := m.resources[id]
	if !exists {
		return nil, pkgerrors.NewNotFoundError("resource not found")
	}
	return resource, nil
}

func (m *MockResourceRepository) ListByVenueID(ctx context.Context, venueID uuid.UUID, activeOnly bool) ([]*entity.Resource, error) {
	if m.shouldError {
		return nil, pkgerrors.NewInternalError("mock error", nil)
	}

	result := []*entity.Resource{}
	for _, resource := range m.resources {
		if resource.VenueID == venueID {
			if !activeOnly || resource.IsActive {
				result = append(result, resource)
			}
		}
	}
	return result, nil
}

func (m *MockResourceRepository) Update(ctx context.Context, resource *entity.Resource) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	if _, exists := m.resources[resource.ID]; !exists {
		return pkgerrors.NewNotFoundError("resource not found")
	}
	m.resources[resource.ID] = resource
	return nil
}

func (m *MockResourceRepository) Delete(ctx context.Context, id uuid.UUID) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	if _, exists := m.resources[id]; !exists {
		return pkgerrors.NewNotFoundError("resource not found")
	}
	delete(m.resources, id)
	return nil
}

func TestResourceService_CreateResource_Success(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	venueID := uuid.New()
	resource, err := svc.CreateResource(
		context.Background(),
		venueID,
		"Tennis Court 1",
		"tennis",
		"hardcourt",
		4,
		true,
	)

	require.NoError(t, err)
	assert.NotNil(t, resource)
	assert.Equal(t, "Tennis Court 1", resource.Name)
	assert.Equal(t, "tennis", resource.SportType)
	assert.Equal(t, 4, resource.Capacity)
	assert.True(t, resource.IsActive)
}

func TestResourceService_CreateResource_InvalidInput(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	tests := []struct {
		name        string
		venueID     uuid.UUID
		resName     string
		sportType   string
		capacity    int
		expectError bool
	}{
		{
			name:        "missing venue_id",
			venueID:     uuid.Nil,
			resName:     "Court 1",
			sportType:   "tennis",
			capacity:    4,
			expectError: true,
		},
		{
			name:        "missing name",
			venueID:     uuid.New(),
			resName:     "",
			sportType:   "tennis",
			capacity:    4,
			expectError: true,
		},
		{
			name:        "missing sport_type",
			venueID:     uuid.New(),
			resName:     "Court 1",
			sportType:   "",
			capacity:    4,
			expectError: true,
		},
		{
			name:        "invalid capacity",
			venueID:     uuid.New(),
			resName:     "Court 1",
			sportType:   "tennis",
			capacity:    0,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := svc.CreateResource(
				context.Background(),
				tt.venueID,
				tt.resName,
				tt.sportType,
				"surface",
				tt.capacity,
				true,
			)

			if tt.expectError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestResourceService_GetResource_Success(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	venueID := uuid.New()
	created, err := svc.CreateResource(
		context.Background(),
		venueID,
		"Tennis Court 1",
		"tennis",
		"hardcourt",
		4,
		true,
	)
	require.NoError(t, err)

	resource, err := svc.GetResource(context.Background(), created.ID)

	require.NoError(t, err)
	assert.NotNil(t, resource)
	assert.Equal(t, created.ID, resource.ID)
	assert.Equal(t, "Tennis Court 1", resource.Name)
}

func TestResourceService_ListResourcesByVenue_Success(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	venueID := uuid.New()

	_, err := svc.CreateResource(context.Background(), venueID, "Court 1", "tennis", "hardcourt", 4, true)
	require.NoError(t, err)
	_, err = svc.CreateResource(context.Background(), venueID, "Court 2", "tennis", "clay", 4, true)
	require.NoError(t, err)
	_, err = svc.CreateResource(context.Background(), venueID, "Court 3", "tennis", "grass", 4, false)
	require.NoError(t, err)

	resources, err := svc.ListResourcesByVenue(context.Background(), venueID, false)
	require.NoError(t, err)
	assert.Len(t, resources, 3)

	activeResources, err := svc.ListResourcesByVenue(context.Background(), venueID, true)
	require.NoError(t, err)
	assert.Len(t, activeResources, 2)
}

func TestResourceService_UpdateResource_Success(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	venueID := uuid.New()
	created, err := svc.CreateResource(
		context.Background(),
		venueID,
		"Tennis Court 1",
		"tennis",
		"hardcourt",
		4,
		true,
	)
	require.NoError(t, err)

	updated, err := svc.UpdateResource(
		context.Background(),
		created.ID,
		"Updated Court",
		"basketball",
		"indoor",
		10,
		false,
	)

	require.NoError(t, err)
	assert.Equal(t, "Updated Court", updated.Name)
	assert.Equal(t, "basketball", updated.SportType)
	assert.Equal(t, 10, updated.Capacity)
	assert.False(t, updated.IsActive)
}

func TestResourceService_DeleteResource_Success(t *testing.T) {
	repo := NewMockResourceRepository()
	svc := service.NewResourceService(repo)

	venueID := uuid.New()
	created, err := svc.CreateResource(
		context.Background(),
		venueID,
		"Tennis Court 1",
		"tennis",
		"hardcourt",
		4,
		true,
	)
	require.NoError(t, err)

	err = svc.DeleteResource(context.Background(), created.ID)
	require.NoError(t, err)

	_, err = svc.GetResource(context.Background(), created.ID)
	assert.Error(t, err)
}

