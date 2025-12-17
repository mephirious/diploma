package usecase

import (
	"context"

	"github.com/diploma/venue-svc/internal/application/schedule/dto"
	"github.com/diploma/venue-svc/internal/domain/schedule/service"
)

type GetResourceScheduleUseCase struct {
	scheduleService *service.ScheduleService
}

func NewGetResourceScheduleUseCase(scheduleService *service.ScheduleService) *GetResourceScheduleUseCase {
	return &GetResourceScheduleUseCase{
		scheduleService: scheduleService,
	}
}

func (uc *GetResourceScheduleUseCase) Execute(ctx context.Context, input dto.GetResourceScheduleInput) (*dto.GetResourceScheduleOutput, error) {
	slots, err := uc.scheduleService.GetResourceSchedule(ctx, input.ResourceID)
	if err != nil {
		return nil, err
	}

	slotDTOs := make([]dto.ScheduleSlotDTO, len(slots))
	for i, slot := range slots {
		slotDTOs[i] = dto.ToScheduleSlotDTO(slot)
	}

	return &dto.GetResourceScheduleOutput{
		Slots: slotDTOs,
	}, nil
}

