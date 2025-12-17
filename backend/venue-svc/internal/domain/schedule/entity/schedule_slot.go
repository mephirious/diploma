package entity

import (
	pkgerrors "github.com/diploma/venue-svc/pkg/errors"
	"github.com/google/uuid"
)

type ScheduleSlot struct {
	ID         uuid.UUID
	ResourceID uuid.UUID
	DayOfWeek  int     // 0=Sunday, 6=Saturday
	StartTime  string  // HH:MM format
	EndTime    string  // HH:MM format
	BasePrice  float64 // Base hourly rate
}

func (s *ScheduleSlot) IsValid() error {
	if s.ResourceID == uuid.Nil {
		return pkgerrors.NewInvalidArgumentError("resource_id is required")
	}
	if s.DayOfWeek < 0 || s.DayOfWeek > 6 {
		return pkgerrors.NewInvalidArgumentError("day_of_week must be 0-6")
	}
	if s.StartTime == "" {
		return pkgerrors.NewInvalidArgumentError("start_time is required")
	}
	if s.EndTime == "" {
		return pkgerrors.NewInvalidArgumentError("end_time is required")
	}
	if s.BasePrice < 0 {
		return pkgerrors.NewInvalidArgumentError("base_price must be non-negative")
	}
	return nil
}

