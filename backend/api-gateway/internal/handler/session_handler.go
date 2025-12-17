package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	sessionv1 "github.com/diploma/api-gateway/api/proto/session/v1"
	"github.com/diploma/api-gateway/internal/client"
	"github.com/diploma/api-gateway/internal/middleware"
	"github.com/go-chi/chi/v5"
)

type SessionHandler struct {
	sessionClient *client.SessionClient
}

func NewSessionHandler(sessionClient *client.SessionClient) *SessionHandler {
	return &SessionHandler{
		sessionClient: sessionClient,
	}
}

type CreateSessionRequest struct {
	ReservationID       string  `json:"reservation_id"`
	SportType           string  `json:"sport_type"`
	SkillLevel          string  `json:"skill_level"`
	MaxParticipants     int     `json:"max_participants"`
	MinParticipants     int     `json:"min_participants"`
	PricePerParticipant float64 `json:"price_per_participant"`
	Description         string  `json:"description"`
}

type SessionResponse struct {
	ID                  string  `json:"id"`
	ReservationID       string  `json:"reservation_id"`
	HostID              string  `json:"host_id"`
	SportType           string  `json:"sport_type"`
	SkillLevel          string  `json:"skill_level"`
	MaxParticipants     int     `json:"max_participants"`
	CurrentParticipants int     `json:"current_participants"`
	PricePerParticipant float64 `json:"price_per_participant"`
	Status              string  `json:"status"`
	Description         string  `json:"description"`
}

func (h *SessionHandler) CreateSession(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req CreateSessionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	resp, err := h.sessionClient.CreateSession(r.Context(), &sessionv1.CreateSessionRequest{
		ReservationId:       req.ReservationID,
		HostId:              userID,
		SportType:           req.SportType,
		SkillLevel:          req.SkillLevel,
		MaxParticipants:     int32(req.MaxParticipants),
		MinParticipants:     int32(req.MinParticipants),
		PricePerParticipant: req.PricePerParticipant,
		Visibility:          sessionv1.SessionVisibility_SESSION_VISIBILITY_PUBLIC,
		Description:         req.Description,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"session_id": resp.SessionId})
}

func (h *SessionHandler) ListOpenSessions(w http.ResponseWriter, r *http.Request) {
	sportType := r.URL.Query().Get("sport_type")
	skillLevel := r.URL.Query().Get("skill_level")
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	pageSize, _ := strconv.Atoi(r.URL.Query().Get("page_size"))

	if page == 0 {
		page = 1
	}
	if pageSize == 0 {
		pageSize = 20
	}

	resp, err := h.sessionClient.ListOpenSessions(r.Context(), &sessionv1.ListOpenSessionsRequest{
		SportType:  sportType,
		SkillLevel: skillLevel,
		Page:       int32(page),
		PageSize:   int32(pageSize),
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	sessions := make([]SessionResponse, len(resp.Items))
	for i, item := range resp.Items {
		sessions[i] = SessionResponse{
			ID:                  item.Id,
			ReservationID:       item.ReservationId,
			HostID:              item.HostId,
			SportType:           item.SportType,
			SkillLevel:          item.SkillLevel,
			MaxParticipants:     int(item.MaxParticipants),
			CurrentParticipants: int(item.CurrentParticipants),
			PricePerParticipant: item.PricePerParticipant,
			Status:              item.Status.String(),
			Description:         item.Description,
		}
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"sessions":    sessions,
		"total_count": resp.TotalCount,
	})
}

func (h *SessionHandler) JoinSession(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	resp, err := h.sessionClient.JoinSession(r.Context(), &sessionv1.JoinSessionRequest{
		SessionId: sessionID,
		UserId:    userID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":        resp.Success,
		"participant_id": resp.ParticipantId,
	})
}

func (h *SessionHandler) CancelSession(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	_, err := h.sessionClient.CancelSession(r.Context(), &sessionv1.CancelSessionRequest{
		SessionId: sessionID,
		UserId:    userID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]bool{"success": true})
}

