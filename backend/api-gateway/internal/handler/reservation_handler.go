package handler

import (
	"encoding/json"
	"net/http"

	reservationv1 "github.com/diploma/api-gateway/api/proto/reservation/v1"
	"github.com/diploma/api-gateway/internal/client"
	"github.com/diploma/api-gateway/internal/middleware"
	"github.com/go-chi/chi/v5"
)

type ReservationHandler struct {
	reservationClient *client.ReservationClient
}

func NewReservationHandler(reservationClient *client.ReservationClient) *ReservationHandler {
	return &ReservationHandler{
		reservationClient: reservationClient,
	}
}

type CreateReservationRequest struct {
	ApartmentID string `json:"apartment_id"`
	Comment     string `json:"comment"`
}

type ReservationResponse struct {
	ID          string `json:"id"`
	UserID      string `json:"user_id"`
	ApartmentID string `json:"apartment_id"`
	ReservedAt  string `json:"reserved_at"`
	Status      string `json:"status"`
	Comment     string `json:"comment"`
}

func (h *ReservationHandler) CreateReservation(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req CreateReservationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	resp, err := h.reservationClient.CreateReservation(r.Context(), &reservationv1.CreateReservationRequest{
		UserId:      userID,
		ApartmentId: req.ApartmentID,
		Comment:     req.Comment,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"reservation_id": resp.ReservationId})
}

func (h *ReservationHandler) ListMyReservations(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	resp, err := h.reservationClient.ListReservationsByUser(r.Context(), &reservationv1.ListReservationsByUserRequest{
		UserId: userID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	reservations := make([]ReservationResponse, len(resp.Items))
	for i, item := range resp.Items {
		reservations[i] = ReservationResponse{
			ID:          item.Id,
			UserID:      item.UserId,
			ApartmentID: item.ApartmentId,
			ReservedAt:  item.ReservedAt,
			Status:      item.Status,
			Comment:     item.Comment,
		}
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"reservations": reservations})
}

func (h *ReservationHandler) GetReservation(w http.ResponseWriter, r *http.Request) {
	reservationID := chi.URLParam(r, "id")

	resp, err := h.reservationClient.GetReservation(r.Context(), &reservationv1.GetReservationRequest{
		ReservationId: reservationID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, ReservationResponse{
		ID:          resp.Id,
		UserID:      resp.UserId,
		ApartmentID: resp.ApartmentId,
		ReservedAt:  resp.ReservedAt,
		Status:      resp.Status,
		Comment:     resp.Comment,
	})
}

func (h *ReservationHandler) CancelReservation(w http.ResponseWriter, r *http.Request) {
	reservationID := chi.URLParam(r, "id")

	_, err := h.reservationClient.CancelReservation(r.Context(), &reservationv1.CancelReservationRequest{
		ReservationId: reservationID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]bool{"success": true})
}

