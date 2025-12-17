package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/schedule/dto"
	"github.com/diploma/venue-svc/internal/domain/schedule/entity"
	"github.com/diploma/venue-svc/internal/domain/schedule/service"
)

type SetResourceScheduleUseCase struct {
	scheduleService *service.ScheduleService
}

func NewSetResourceScheduleUseCase(scheduleService *service.ScheduleService) *SetResourceScheduleUseCase {
	return &SetResourceScheduleUseCase{
		scheduleService: scheduleService,
	}
}

func (uc *SetResourceScheduleUseCase) Execute(ctx context.Context, input dto.SetResourceScheduleInput) (*dto.SetResourceScheduleOutput, error) {
	slots := make([]*entity.ScheduleSlot, len(input.Slots))
	for i, slotDTO := range input.Slots {
		slots[i] = dto.ToScheduleSlotEntity(slotDTO, input.ResourceID)
	}

	err := uc.scheduleService.SetResourceSchedule(ctx, input.ResourceID, slots)
	if err != nil {
		return nil, err
	}

	return &dto.SetResourceScheduleOutput{
		Success: true,
	}, nil
}

