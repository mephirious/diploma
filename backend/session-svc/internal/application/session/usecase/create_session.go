package usecase

import (
	"context"

	participantEntity "github.com/diploma/session-svc/internal/domain/participant/entity"
	participantService "github.com/diploma/session-svc/internal/domain/participant/service"
	"github.com/diploma/session-svc/internal/domain/session/service"
	"github.com/diploma/session-svc/internal/application/session/dto"
)

type CreateSessionUseCase struct {
	sessionService     *service.SessionService
	participantService *participantService.ParticipantService
	eventPublisher     EventPublisher
}

func NewCreateSessionUseCase(
	sessionService *service.SessionService,
	participantService *participantService.ParticipantService,
	eventPublisher EventPublisher,
) *CreateSessionUseCase {
	return &CreateSessionUseCase{
		sessionService:     sessionService,
		participantService: participantService,
		eventPublisher:     eventPublisher,
	}
}

func (uc *CreateSessionUseCase) Execute(ctx context.Context, input dto.CreateSessionInput) (*dto.CreateSessionOutput, error) {
	session, err := uc.sessionService.CreateSession(
		ctx,
		input.ReservationID,
		input.HostID,
		input.SportType,
		input.SkillLevel,
		input.MaxParticipants,
		input.MinParticipants,
		input.PricePerParticipant,
		input.Visibility,
		input.Description,
	)
	if err != nil {
		return nil, err
	}

	_, err = uc.participantService.AddParticipant(ctx, session.ID, input.HostID, participantEntity.ParticipantRoleHost)
	if err != nil {
		return nil, err
	}

	if uc.eventPublisher != nil {
		_ = uc.eventPublisher.PublishSessionCreated(ctx, session.ID, session.ReservationID, session.HostID)
	}

	return &dto.CreateSessionOutput{
		SessionID: session.ID,
	}, nil
}

