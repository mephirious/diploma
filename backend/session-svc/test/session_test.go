package test

import (
	"context"
	"testing"
	"time"

	"github.com/diploma/session-svc/internal/domain/participant/entity"
	participantPort "github.com/diploma/session-svc/internal/domain/participant/port"
	sessionEntity "github.com/diploma/session-svc/internal/domain/session/entity"
	"github.com/diploma/session-svc/internal/domain/session/port"
	"github.com/diploma/session-svc/internal/domain/session/service"
	"github.com/google/uuid"
)

type MockSessionRepo struct {
	sessions map[uuid.UUID]*sessionEntity.Session
}

func NewMockSessionRepo() *MockSessionRepo {
	return &MockSessionRepo{sessions: make(map[uuid.UUID]*sessionEntity.Session)}
}

func (m *MockSessionRepo) Create(ctx context.Context, s *sessionEntity.Session) error {
	m.sessions[s.ID] = s
	return nil
}

func (m *MockSessionRepo) GetByID(ctx context.Context, id uuid.UUID) (*sessionEntity.Session, error) {
	if s, ok := m.sessions[id]; ok {
		return s, nil
	}
	return nil, nil
}

func (m *MockSessionRepo) GetByReservationID(ctx context.Context, reservationID uuid.UUID) (*sessionEntity.Session, error) {
	for _, s := range m.sessions {
		if s.ReservationID == reservationID {
			return s, nil
		}
	}
	return nil, nil
}

func (m *MockSessionRepo) ListOpen(ctx context.Context, sportType, skillLevel string, offset, limit int) ([]*sessionEntity.Session, int, error) {
	return nil, 0, nil
}

func (m *MockSessionRepo) ListByUserID(ctx context.Context, userID uuid.UUID, offset, limit int) ([]*sessionEntity.Session, int, error) {
	return nil, 0, nil
}

func (m *MockSessionRepo) Update(ctx context.Context, s *sessionEntity.Session) error {
	m.sessions[s.ID] = s
	return nil
}

func (m *MockSessionRepo) Delete(ctx context.Context, id uuid.UUID) error {
	delete(m.sessions, id)
	return nil
}

type MockParticipantRepo struct {
	participants map[uuid.UUID]*entity.Participant
}

func NewMockParticipantRepo() *MockParticipantRepo {
	return &MockParticipantRepo{participants: make(map[uuid.UUID]*entity.Participant)}
}

func (m *MockParticipantRepo) Create(ctx context.Context, p *entity.Participant) error {
	m.participants[p.ID] = p
	return nil
}

func (m *MockParticipantRepo) GetByID(ctx context.Context, id uuid.UUID) (*entity.Participant, error) {
	if p, ok := m.participants[id]; ok {
		return p, nil
	}
	return nil, nil
}

func (m *MockParticipantRepo) GetBySessionAndUser(ctx context.Context, sessionID, userID uuid.UUID) (*entity.Participant, error) {
	return nil, nil
}

func (m *MockParticipantRepo) ListBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	var result []*entity.Participant
	for _, p := range m.participants {
		if p.SessionID == sessionID {
			result = append(result, p)
		}
	}
	return result, nil
}

func (m *MockParticipantRepo) ListActiveBySessionID(ctx context.Context, sessionID uuid.UUID) ([]*entity.Participant, error) {
	return m.ListBySessionID(ctx, sessionID)
}

func (m *MockParticipantRepo) CountActiveBySessionID(ctx context.Context, sessionID uuid.UUID) (int, error) {
	list, _ := m.ListBySessionID(ctx, sessionID)
	return len(list), nil
}

func (m *MockParticipantRepo) Update(ctx context.Context, p *entity.Participant) error {
	m.participants[p.ID] = p
	return nil
}

func (m *MockParticipantRepo) Delete(ctx context.Context, id uuid.UUID) error {
	delete(m.participants, id)
	return nil
}

var _ port.SessionRepository = (*MockSessionRepo)(nil)
var _ participantPort.ParticipantRepository = (*MockParticipantRepo)(nil)

func TestCreateSession(t *testing.T) {
	sessionRepo := NewMockSessionRepo()
	participantRepo := NewMockParticipantRepo()
	svc := service.NewSessionService(sessionRepo, participantRepo)

	ctx := context.Background()
	session, err := svc.CreateSession(
		ctx,
		uuid.New(),
		uuid.New(),
		"tennis",
		"intermediate",
		4,
		2,
		15.0,
		sessionEntity.SessionVisibilityPublic,
		"Test session",
	)

	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if session.ID == uuid.Nil {
		t.Error("Expected valid session ID")
	}

	if session.Status != sessionEntity.SessionStatusOpen {
		t.Errorf("Expected status OPEN, got %v", session.Status)
	}
}

func TestGetSession(t *testing.T) {
	sessionRepo := NewMockSessionRepo()
	participantRepo := NewMockParticipantRepo()
	svc := service.NewSessionService(sessionRepo, participantRepo)

	ctx := context.Background()
	session := &sessionEntity.Session{
		ID:              uuid.New(),
		ReservationID:   uuid.New(),
		HostID:          uuid.New(),
		SportType:       "tennis",
		MaxParticipants: 4,
		Status:          sessionEntity.SessionStatusOpen,
		CreatedAt:       time.Now(),
	}

	sessionRepo.Create(ctx, session)

	result, err := svc.GetSession(ctx, session.ID)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if result.ID != session.ID {
		t.Errorf("Expected session ID %v, got %v", session.ID, result.ID)
	}
}

