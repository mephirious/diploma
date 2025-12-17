package repository

import (
	"context"
	"errors"

	"github.com/diploma/session-svc/internal/domain/participant/entity"
	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ParticipantRepositoryImpl struct {
	db *gorm.DB
}

func NewParticipantRepository(db *gorm.DB) *ParticipantRepositoryImpl {
	return &ParticipantRepositoryImpl{db: db}
}

func (r *ParticipantRepositoryImpl) Create(ctx context.Context, participant *entity.Participant) error {
	result := r.db.WithContext(ctx).Create(participant)
	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to create participant", result.Error)
	}
	return nil
}

func (r *ParticipantRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Participant, error) {
	var p entity.Participant
	result := r.db.WithContext(ctx).Where("id = ?", id).First(&p)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError("participant not found")
		}
		return nil, pkgerrors.NewInternalError("failed to get participant", result.Error)
	}
	return &p, nil
}

func (r *ParticipantRepositoryImpl) GetBySessionAndUser(ctx context.Context, sessionID, userID uuid.UUID) (*entity.Participant, error) {
	var p entity.Participant
	result := r.db.WithContext(ctx).Where("session_id = ? AND user_id = ?", sessionID, userID).Order("joined_at DESC").First(&p)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError("participant not found")
		}
		return nil, pkgerrors.NewInternalError("failed to get participant", result.Error)
	}
	return &p, nil
}

func (r *ParticipantRepositoryImpl) ListBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	var participants []*entity.Participant
	result := r.db.WithContext(ctx).Where("session_id = ?", sessionID).Order("joined_at").Find(&participants)

	if result.Error != nil {
		return nil, pkgerrors.NewInternalError("failed to list participants", result.Error)
	}
	return participants, nil
}

func (r *ParticipantRepositoryImpl) ListActiveBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	var participants []*entity.Participant
	result := r.db.WithContext(ctx).Where("session_id = ? AND status = ?", sessionID, "JOINED").Order("joined_at").Find(&participants)

	if result.Error != nil {
		return nil, pkgerrors.NewInternalError("failed to list active participants", result.Error)
	}
	return participants, nil
}

func (r *ParticipantRepositoryImpl) CountActiveBySessionID(ctx context.Context, sessionID uuid.UUID) (int, error) {
	var count int64
	result := r.db.WithContext(ctx).Model(&entity.Participant{}).Where("session_id = ? AND status = ?", sessionID, "JOINED").Count(&count)

	if result.Error != nil {
		return 0, pkgerrors.NewInternalError("failed to count participants", result.Error)
	}
	return int(count), nil
}

func (r *ParticipantRepositoryImpl) Update(ctx context.Context, participant *entity.Participant) error {
	result := r.db.WithContext(ctx).Model(&entity.Participant{}).Where("id = ?", participant.ID).Update("status", participant.Status)

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to update participant", result.Error)
	}
	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError("participant not found")
	}
	return nil
}

func (r *ParticipantRepositoryImpl) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Where("id = ?", id).Delete(&entity.Participant{})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to delete participant", result.Error)
	}
	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError("participant not found")
	}
	return nil
}
