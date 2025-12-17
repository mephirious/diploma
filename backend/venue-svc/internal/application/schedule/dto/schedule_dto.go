package dto

import (
	scheduleEntity "github.com/diploma/venue-svc/internal/domain/schedule/entity"
	"github.com/google/uuid"
)

type ScheduleSlotDTO struct {
	DayOfWeek int
	StartTime string
	EndTime   string
	BasePrice float64
}

type SetResourceScheduleInput struct {
	ResourceID uuid.UUID
	Slots      []ScheduleSlotDTO
}

type SetResourceScheduleOutput struct {
	Success bool
}

type GetResourceScheduleInput struct {
	ResourceID uuid.UUID
}

type GetResourceScheduleOutput struct {
	Slots []ScheduleSlotDTO
}

func ToScheduleSlotDTO(slot *scheduleEntity.ScheduleSlot) ScheduleSlotDTO {
	return ScheduleSlotDTO{
		DayOfWeek: slot.DayOfWeek,
		StartTime: slot.StartTime,
		EndTime:   slot.EndTime,
		BasePrice: slot.BasePrice,
	}
}

func ToScheduleSlotEntity(dto ScheduleSlotDTO, resourceID uuid.UUID) *scheduleEntity.ScheduleSlot {
	return &scheduleEntity.ScheduleSlot{
		ID:         uuid.New(),
		ResourceID: resourceID,
		DayOfWeek:  dto.DayOfWeek,
		StartTime:  dto.StartTime,
		EndTime:    dto.EndTime,
		BasePrice:  dto.BasePrice,
	}
}

