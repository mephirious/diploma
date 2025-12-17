package service

import (
	"context"
	"fmt"

	"github.com/diploma/venue-svc/internal/domain/schedule/entity"
	"github.com/diploma/venue-svc/internal/domain/schedule/port"
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type ScheduleService struct {
	repo port.ScheduleRepository
}

func NewScheduleService(repo port.ScheduleRepository) *ScheduleService {
	return &ScheduleService{
		repo: repo,
	}
}

func (s *ScheduleService) SetResourceSchedule(ctx context.Context, resourceID uuid.UUID, slots []*entity.ScheduleSlot) error {
	if resourceID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("resource_id is required")
	}

	for i, slot := range slots {
		slot.ResourceID = resourceID
		if slot.ID == uuid.Nil {
			slot.ID = uuid.New()
		}
		if err := slot.IsValid(); err != nil {
			return fmt.Errorf("slot %d invalid: %w", i, err)
		}
	}

	if err := s.repo.DeleteByResourceID(ctx, resourceID); err != nil {
		return fmt.Errorf("failed to delete existing schedule: %w", err)
	}

	if len(slots) > 0 {
		if err := s.repo.CreateBatch(ctx, slots); err != nil {
			return fmt.Errorf("failed to create schedule: %w", err)
		}
	}

	return nil
}

func (s *ScheduleService) GetResourceSchedule(ctx context.Context, resourceID uuid.UUID) ([]*entity.ScheduleSlot, error) {
	if resourceID == uuid.Nil {
		return nil, pkgerrors.NewInvalidArgumentError("resource_id is required")
	}
	return s.repo.GetByResourceID(ctx, resourceID)
}

