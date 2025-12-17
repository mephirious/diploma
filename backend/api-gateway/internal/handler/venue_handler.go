package handler

import (
	"net/http"
	"strconv"

	venuev1 "github.com/diploma/api-gateway/api/proto/venue/v1"
	"github.com/diploma/api-gateway/internal/client"
	"github.com/go-chi/chi/v5"
)

type VenueHandler struct {
	venueClient *client.VenueClient
}

func NewVenueHandler(venueClient *client.VenueClient) *VenueHandler {
	return &VenueHandler{
		venueClient: venueClient,
	}
}

type VenueResponse struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	City        string  `json:"city"`
	Address     string  `json:"address"`
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
}

type ListVenuesResponse struct {
	Items      []VenueResponse `json:"items"`
	TotalCount int             `json:"total_count"`
}

func (h *VenueHandler) ListVenues(w http.ResponseWriter, r *http.Request) {
	city := r.URL.Query().Get("city")
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	pageSize, _ := strconv.Atoi(r.URL.Query().Get("page_size"))

	if page == 0 {
		page = 1
	}
	if pageSize == 0 {
		pageSize = 20
	}

	resp, err := h.venueClient.ListVenues(r.Context(), &venuev1.ListVenuesRequest{
		City:     city,
		Page:     int32(page),
		PageSize: int32(pageSize),
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	items := make([]VenueResponse, len(resp.Items))
	for i, item := range resp.Items {
		items[i] = VenueResponse{
			ID:          item.Id,
			Name:        item.Name,
			Description: item.Description,
			City:        item.City,
			Address:     item.Address,
			Latitude:    item.Latitude,
			Longitude:   item.Longitude,
		}
	}

	writeJSON(w, http.StatusOK, ListVenuesResponse{
		Items:      items,
		TotalCount: int(resp.TotalCount),
	})
}

func (h *VenueHandler) GetVenue(w http.ResponseWriter, r *http.Request) {
	venueID := chi.URLParam(r, "id")

	resp, err := h.venueClient.GetVenue(r.Context(), &venuev1.GetVenueRequest{
		VenueId: venueID,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, VenueResponse{
		ID:          resp.Id,
		Name:        resp.Name,
		Description: resp.Description,
		City:        resp.City,
		Address:     resp.Address,
		Latitude:    resp.Latitude,
		Longitude:   resp.Longitude,
	})
}

type ResourceResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	SportType   string `json:"sport_type"`
	Capacity    int    `json:"capacity"`
	SurfaceType string `json:"surface_type"`
	IsActive    bool   `json:"is_active"`
}

func (h *VenueHandler) ListResources(w http.ResponseWriter, r *http.Request) {
	venueID := chi.URLParam(r, "id")

	resp, err := h.venueClient.ListResourcesByVenue(r.Context(), &venuev1.ListResourcesByVenueRequest{
		VenueId:    venueID,
		ActiveOnly: true,
	})
	if err != nil {
		writeGRPCError(w, err)
		return
	}

	resources := make([]ResourceResponse, len(resp.Items))
	for i, item := range resp.Items {
		resources[i] = ResourceResponse{
			ID:          item.Id,
			Name:        item.Name,
			SportType:   item.SportType,
			Capacity:    int(item.Capacity),
			SurfaceType: item.SurfaceType,
			IsActive:    item.IsActive,
		}
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"resources": resources})
}

