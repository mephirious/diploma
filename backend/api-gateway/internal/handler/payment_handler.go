package handler

import (
	"net/http"

	paymentv1 "github.com/diploma/api-gateway/api/proto/payment/v1"
	"github.com/diploma/api-gateway/internal/client"
	"github.com/diploma/api-gateway/internal/middleware"
	"github.com/go-chi/chi/v5"
)

type PaymentHandler struct {
	paymentClient *client.PaymentClient
}

func NewPaymentHandler(paymentClient *client.PaymentClient) *PaymentHandler {
	return &PaymentHandler{
		paymentClient: paymentClient,
	}
}

type StartPaymentResponse struct {
	PaymentID    string  `json:"payment_id"`
	ClientSecret string  `json:"client_secret"`
	Amount       float64 `json:"amount"`
	Currency     string  `json:"currency"`
}

func (h *PaymentHandler) StartPayment(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	resp, err := h.paymentClient.StartPaymentForSession(r.Context(), &paymentv1.StartPaymentForSessionRequest{
		SessionId: sessionID,
		UserId:    userID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, StartPaymentResponse{
		PaymentID:    resp.PaymentId,
		ClientSecret: resp.ClientSecret,
		Amount:       resp.Amount,
		Currency:     resp.Currency,
	})
}

type PaymentResponse struct {
	ID                    string  `json:"id"`
	SessionID             string  `json:"session_id"`
	UserID                string  `json:"user_id"`
	Amount                float64 `json:"amount"`
	Currency              string  `json:"currency"`
	StripePaymentIntentID string  `json:"stripe_payment_intent_id"`
	Status                string  `json:"status"`
}

func (h *PaymentHandler) GetPaymentsBySession(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "id")

	resp, err := h.paymentClient.GetPaymentsBySession(r.Context(), &paymentv1.GetPaymentsBySessionRequest{
		SessionId: sessionID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	payments := make([]PaymentResponse, len(resp.Payments))
	for i, item := range resp.Payments {
		payments[i] = PaymentResponse{
			ID:                    item.Id,
			SessionID:             item.SessionId,
			UserID:                item.UserId,
			Amount:                item.Amount,
			Currency:              item.Currency,
			StripePaymentIntentID: item.StripePaymentIntentId,
			Status:                item.Status.String(),
		}
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"payments": payments})
}

