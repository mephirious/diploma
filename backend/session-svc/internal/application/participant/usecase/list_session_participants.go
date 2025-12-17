package usecase

import (
	"context"

	"github.com/diploma/session-svc/internal/application/participant/dto"
	"github.com/diploma/session-svc/internal/domain/participant/service"
)

type ListSessionParticipantsUseCase struct {
	participantService *service.ParticipantService
}

func NewListSessionParticipantsUseCase(participantService *service.ParticipantService) *ListSessionParticipantsUseCase {
	return &ListSessionParticipantsUseCase{
		participantService: participantService,
	}
}

func (uc *ListSessionParticipantsUseCase) Execute(ctx context.Context, input dto.ListSessionParticipantsInput) (*dto.ListSessionParticipantsOutput, error) {
	participants, err := uc.participantService.ListSessionParticipants(ctx, input.SessionID)
	if err != nil {
		return nil, err
	}

	outputs := make([]dto.ParticipantOutput, len(participants))
	for i, participant := range participants {
		outputs[i] = dto.ToParticipantOutput(participant)
	}

	return &dto.ListSessionParticipantsOutput{
		Participants: outputs,
	}, nil
}

