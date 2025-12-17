package test

import (
	"context"
	"testing"

	"github.com/diploma/venue-svc/internal/domain/schedule/entity"
	"github.com/diploma/venue-svc/internal/domain/schedule/service"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type MockScheduleRepository struct {
	slots       map[uuid.UUID][]*entity.ScheduleSlot // keyed by resource_id
	shouldError bool
}

func NewMockScheduleRepository() *MockScheduleRepository {
	return &MockScheduleRepository{
		slots: make(map[uuid.UUID][]*entity.ScheduleSlot),
	}
}

func (m *MockScheduleRepository) CreateBatch(ctx context.Context, slots []*entity.ScheduleSlot) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}

	if len(slots) == 0 {
		return nil
	}

	resourceID := slots[0].ResourceID
	if _, exists := m.slots[resourceID]; !exists {
		m.slots[resourceID] = []*entity.ScheduleSlot{}
	}
	m.slots[resourceID] = append(m.slots[resourceID], slots...)
	return nil
}

func (m *MockScheduleRepository) GetByResourceID(ctx context.Context, resourceID uuid.UUID) ([]*entity.ScheduleSlot, error) {
	if m.shouldError {
		return nil, pkgerrors.NewInternalError("mock error", nil)
	}

	slots, exists := m.slots[resourceID]
	if !exists {
		return []*entity.ScheduleSlot{}, nil
	}
	return slots, nil
}

func (m *MockScheduleRepository) DeleteByResourceID(ctx context.Context, resourceID uuid.UUID) error {
	if m.shouldError {
		return pkgerrors.NewInternalError("mock error", nil)
	}
	delete(m.slots, resourceID)
	return nil
}

func TestScheduleService_SetResourceSchedule_Success(t *testing.T) {
	repo := NewMockScheduleRepository()
	svc := service.NewScheduleService(repo)

	resourceID := uuid.New()
	slots := []*entity.ScheduleSlot{
		{
			ID:         uuid.New(),
			ResourceID: resourceID,
			DayOfWeek:  1, // Monday
			StartTime:  "09:00",
			EndTime:    "12:00",
			BasePrice:  50.0,
		},
		{
			ID:         uuid.New(),
			ResourceID: resourceID,
			DayOfWeek:  1,
			StartTime:  "13:00",
			EndTime:    "18:00",
			BasePrice:  75.0,
		},
	}

	err := svc.SetResourceSchedule(context.Background(), resourceID, slots)
	require.NoError(t, err)

	savedSlots, err := svc.GetResourceSchedule(context.Background(), resourceID)
	require.NoError(t, err)
	assert.Len(t, savedSlots, 2)
}

func TestScheduleService_SetResourceSchedule_InvalidSlot(t *testing.T) {
	repo := NewMockScheduleRepository()
	svc := service.NewScheduleService(repo)

	resourceID := uuid.New()

	tests := []struct {
		name        string
		slot        *entity.ScheduleSlot
		expectError bool
	}{
		{
			name: "invalid day_of_week (negative)",
			slot: &entity.ScheduleSlot{
				ID:         uuid.New(),
				ResourceID: resourceID,
				DayOfWeek:  -1,
				StartTime:  "09:00",
				EndTime:    "12:00",
				BasePrice:  50.0,
			},
			expectError: true,
		},
		{
			name: "invalid day_of_week (>6)",
			slot: &entity.ScheduleSlot{
				ID:         uuid.New(),
				ResourceID: resourceID,
				DayOfWeek:  7,
				StartTime:  "09:00",
				EndTime:    "12:00",
				BasePrice:  50.0,
			},
			expectError: true,
		},
		{
			name: "missing start_time",
			slot: &entity.ScheduleSlot{
				ID:         uuid.New(),
				ResourceID: resourceID,
				DayOfWeek:  1,
				StartTime:  "",
				EndTime:    "12:00",
				BasePrice:  50.0,
			},
			expectError: true,
		},
		{
			name: "missing end_time",
			slot: &entity.ScheduleSlot{
				ID:         uuid.New(),
				ResourceID: resourceID,
				DayOfWeek:  1,
				StartTime:  "09:00",
				EndTime:    "",
				BasePrice:  50.0,
			},
			expectError: true,
		},
		{
			name: "negative base_price",
			slot: &entity.ScheduleSlot{
				ID:         uuid.New(),
				ResourceID: resourceID,
				DayOfWeek:  1,
				StartTime:  "09:00",
				EndTime:    "12:00",
				BasePrice:  -10.0,
			},
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := svc.SetResourceSchedule(context.Background(), resourceID, []*entity.ScheduleSlot{tt.slot})

			if tt.expectError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestScheduleService_GetResourceSchedule_EmptySchedule(t *testing.T) {
	repo := NewMockScheduleRepository()
	svc := service.NewScheduleService(repo)

	resourceID := uuid.New()
	slots, err := svc.GetResourceSchedule(context.Background(), resourceID)

	require.NoError(t, err)
	assert.Empty(t, slots)
}

func TestScheduleService_ReplaceSchedule(t *testing.T) {
	repo := NewMockScheduleRepository()
	svc := service.NewScheduleService(repo)

	resourceID := uuid.New()

	initialSlots := []*entity.ScheduleSlot{
		{
			ID:         uuid.New(),
			ResourceID: resourceID,
			DayOfWeek:  1,
			StartTime:  "09:00",
			EndTime:    "12:00",
			BasePrice:  50.0,
		},
	}
	err := svc.SetResourceSchedule(context.Background(), resourceID, initialSlots)
	require.NoError(t, err)

	newSlots := []*entity.ScheduleSlot{
		{
			ID:         uuid.New(),
			ResourceID: resourceID,
			DayOfWeek:  2,
			StartTime:  "10:00",
			EndTime:    "14:00",
			BasePrice:  60.0,
		},
		{
			ID:         uuid.New(),
			ResourceID: resourceID,
			DayOfWeek:  3,
			StartTime:  "10:00",
			EndTime:    "14:00",
			BasePrice:  60.0,
		},
	}
	err = svc.SetResourceSchedule(context.Background(), resourceID, newSlots)
	require.NoError(t, err)

	savedSlots, err := svc.GetResourceSchedule(context.Background(), resourceID)
	require.NoError(t, err)
	assert.NotEmpty(t, savedSlots)
}

