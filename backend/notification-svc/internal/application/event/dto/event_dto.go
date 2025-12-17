package dto

type ReservationCreatedEvent struct {
	ReservationID string `json:"reservation_id"`
	UserID        string `json:"user_id"`
	ApartmentID   string `json:"apartment_id"`
	ReservedAt    string `json:"reserved_at"`
}

type ReservationConfirmedEvent struct {
	ReservationID string `json:"reservation_id"`
	UserID        string `json:"user_id"`
}

type ReservationCancelledEvent struct {
	ReservationID string `json:"reservation_id"`
	UserID        string `json:"user_id"`
}

type SessionCreatedEvent struct {
	SessionID     string `json:"session_id"`
	ReservationID string `json:"reservation_id"`
	HostID        string `json:"host_id"`
}

type SessionJoinedEvent struct {
	SessionID           string `json:"session_id"`
	UserID              string `json:"user_id"`
	CurrentParticipants int    `json:"current_participants"`
}

type SessionFullEvent struct {
	SessionID string `json:"session_id"`
}

type SessionCancelledEvent struct {
	SessionID string `json:"session_id"`
}

type SessionLeftEvent struct {
	SessionID string `json:"session_id"`
	UserID    string `json:"user_id"`
}

type PaymentCreatedEvent struct {
	PaymentID string  `json:"payment_id"`
	SessionID string  `json:"session_id"`
	UserID    string  `json:"user_id"`
	Amount    float64 `json:"amount"`
}

type PaymentSucceededEvent struct {
	PaymentID string  `json:"payment_id"`
	SessionID string  `json:"session_id"`
	UserID    string  `json:"user_id"`
	Amount    float64 `json:"amount"`
}

type PaymentFailedEvent struct {
	PaymentID string `json:"payment_id"`
	SessionID string `json:"session_id"`
	UserID    string `json:"user_id"`
	Reason    string `json:"reason"`
}

type PaymentRefundedEvent struct {
	PaymentID string `json:"payment_id"`
	SessionID string `json:"session_id"`
	UserID    string `json:"user_id"`
	RefundID  string `json:"refund_id"`
}

