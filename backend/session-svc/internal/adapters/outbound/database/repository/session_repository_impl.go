package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/diploma/session-svc/internal/domain/session/entity"
	pkgerrors "github.com/diploma/session-svc/pkg/errors"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SessionRepositoryImpl struct {
	db *gorm.DB
}

func NewSessionRepository(db *gorm.DB) *SessionRepositoryImpl {
	return &SessionRepositoryImpl{
		db: db,
	}
}

func (r *SessionRepositoryImpl) Create(ctx context.Context, session *entity.Session) error {
	result := r.db.WithContext(ctx).Create(session)
	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to create session", result.Error)
	}

	return nil
}

func (r *SessionRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Session, error) {
	var session entity.Session
	result := r.db.WithContext(ctx).Where("id = ?", id).First(&session)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, pkgerrors.NewNotFoundError(fmt.Sprintf("session not found: %s", id))
		}
		return nil, pkgerrors.NewInternalError("failed to get session", result.Error)
	}

	return &session, nil
}

func (r *SessionRepositoryImpl) GetByReservationID(ctx context.Context, reservationID uuid.UUID) (*entity.Session, error) {
	var session entity.Session
	result := r.db.WithContext(ctx).Where("reservation_id = ?", reservationID).First(&session)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, pkgerrors.NewInternalError("failed to get session by reservation", result.Error)
	}

	return &session, nil
}

func (r *SessionRepositoryImpl) ListOpen(ctx context.Context, sportType, skillLevel string, offset, limit int) ([]*entity.Session, int, error) {
	var totalCount int64
	query := r.db.WithContext(ctx).Model(&entity.Session{}).Where("status IN (?, ?) AND visibility = ?", "OPEN", "FULL", "PUBLIC")

	if sportType != "" {
		query = query.Where("sport_type = ?", sportType)
	}
	if skillLevel != "" {
		query = query.Where("skill_level = ?", skillLevel)
	}

	if err := query.Count(&totalCount).Error; err != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to count sessions", err)
	}

	var sessions []*entity.Session
	result := query.Order("created_at DESC").Offset(offset).Limit(limit).Find(&sessions)

	if result.Error != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to list sessions", result.Error)
	}

	return sessions, int(totalCount), nil
}

func (r *SessionRepositoryImpl) ListByUserID(ctx context.Context, userID uuid.UUID, offset, limit int) ([]*entity.Session, int, error) {
	var totalCount int64
	countQuery := r.db.WithContext(ctx).Table("sessions s").
		Joins("INNER JOIN session_participants sp ON s.id = sp.session_id").
		Where("sp.user_id = ? AND sp.status = ?", userID, "JOINED")

	if err := countQuery.Count(&totalCount).Error; err != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to count user sessions", err)
	}

	var sessions []*entity.Session
	result := r.db.WithContext(ctx).Table("sessions s").
		Select("DISTINCT s.*").
		Joins("INNER JOIN session_participants sp ON s.id = sp.session_id").
		Where("sp.user_id = ? AND sp.status = ?", userID, "JOINED").
		Order("s.created_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&sessions)

	if result.Error != nil {
		return nil, 0, pkgerrors.NewInternalError("failed to list user sessions", result.Error)
	}

	return sessions, int(totalCount), nil
}

func (r *SessionRepositoryImpl) Update(ctx context.Context, session *entity.Session) error {
	result := r.db.WithContext(ctx).Model(&entity.Session{}).Where("id = ?", session.ID).Updates(map[string]interface{}{
		"sport_type":            session.SportType,
		"skill_level":           session.SkillLevel,
		"max_participants":      session.MaxParticipants,
		"min_participants":      session.MinParticipants,
		"current_participants":  session.CurrentParticipants,
		"price_per_participant": session.PricePerParticipant,
		"visibility":            session.Visibility,
		"status":                session.Status,
		"description":           session.Description,
	})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to update session", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("session not found: %s", session.ID))
	}

	return nil
}

func (r *SessionRepositoryImpl) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Where("id = ?", id).Delete(&entity.Session{})

	if result.Error != nil {
		return pkgerrors.NewInternalError("failed to delete session", result.Error)
	}

	if result.RowsAffected == 0 {
		return pkgerrors.NewNotFoundError(fmt.Sprintf("session not found: %s", id))
	}

	return nil
}
