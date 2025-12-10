package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/diploma/reservation-svc/internal/domain/reservation/entity"
	"github.com/diploma/reservation-svc/internal/domain/reservation/port"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ReservationRepositoryImpl struct {
	pool *pgxpool.Pool
}

func NewReservationRepositoryImpl(pool *pgxpool.Pool) port.ReservationRepository {
	return &ReservationRepositoryImpl{
		pool: pool,
	}
}

func (r *ReservationRepositoryImpl) Create(ctx context.Context, reservation *entity.Reservation) error {
	query := `
		INSERT INTO reservations (id, user_id, apartment_id, status, reserved_at, expires_at, comment)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING reserved_at
	`

	var reservedAt time.Time
	err := r.pool.QueryRow(
		ctx,
		query,
		reservation.ID,
		reservation.UserID,
		reservation.ApartmentID,
		string(reservation.Status),
		time.Now(),
		reservation.ExpiresAt,
		reservation.Comment,
	).Scan(&reservedAt)

	if err != nil {
		return fmt.Errorf("failed to create reservation: %w", err)
	}

	reservation.ReservedAt = reservedAt
	return nil
}

func (r *ReservationRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*entity.Reservation, error) {
	query := `
		SELECT id, user_id, apartment_id, status, reserved_at, expires_at, comment
		FROM reservations
		WHERE id = $1
	`

	reservation := &entity.Reservation{}
	var statusStr string
	var expiresAt sql.NullTime
	var comment sql.NullString

	err := r.pool.QueryRow(ctx, query, id).Scan(
		&reservation.ID,
		&reservation.UserID,
		&reservation.ApartmentID,
		&statusStr,
		&reservation.ReservedAt,
		&expiresAt,
		&comment,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("reservation not found: %w", err)
		}
		return nil, fmt.Errorf("failed to get reservation: %w", err)
	}

	reservation.Status = entity.ReservationStatus(statusStr)
	if expiresAt.Valid {
		reservation.ExpiresAt = &expiresAt.Time
	}
	if comment.Valid {
		reservation.Comment = &comment.String
	}

	return reservation, nil
}

func (r *ReservationRepositoryImpl) Update(ctx context.Context, reservation *entity.Reservation) error {
	query := `
		UPDATE reservations
		SET status = $2, expires_at = $3, comment = $4
		WHERE id = $1
	`

	result, err := r.pool.Exec(
		ctx,
		query,
		reservation.ID,
		string(reservation.Status),
		reservation.ExpiresAt,
		reservation.Comment,
	)

	if err != nil {
		return fmt.Errorf("failed to update reservation: %w", err)
	}

	if result.RowsAffected() == 0 {
		return fmt.Errorf("reservation not found")
	}

	return nil
}

func (r *ReservationRepositoryImpl) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Reservation, error) {
	query := `
		SELECT id, user_id, apartment_id, status, reserved_at, expires_at, comment
		FROM reservations
		WHERE user_id = $1
		ORDER BY reserved_at DESC
	`

	rows, err := r.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to list reservations: %w", err)
	}
	defer rows.Close()

	var reservations []*entity.Reservation
	for rows.Next() {
		reservation := &entity.Reservation{}
		var statusStr string
		var expiresAt sql.NullTime
		var comment sql.NullString

		if err := rows.Scan(
			&reservation.ID,
			&reservation.UserID,
			&reservation.ApartmentID,
			&statusStr,
			&reservation.ReservedAt,
			&expiresAt,
			&comment,
		); err != nil {
			return nil, fmt.Errorf("failed to scan reservation: %w", err)
		}

		reservation.Status = entity.ReservationStatus(statusStr)
		if expiresAt.Valid {
			reservation.ExpiresAt = &expiresAt.Time
		}
		if comment.Valid {
			reservation.Comment = &comment.String
		}

		reservations = append(reservations, reservation)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating reservations: %w", err)
	}

	return reservations, nil
}

