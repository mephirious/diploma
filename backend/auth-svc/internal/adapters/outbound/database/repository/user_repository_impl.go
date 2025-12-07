package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/diploma/auth-svc/internal/domain/user/entity"
	"github.com/diploma/auth-svc/internal/domain/user/port"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

type UserRepositoryImpl struct {
	pool *pgxpool.Pool
}

func NewUserRepositoryImpl(pool *pgxpool.Pool) port.UserRepository {
	return &UserRepositoryImpl{
		pool: pool,
	}
}

func (r *UserRepositoryImpl) Create(ctx context.Context, user *entity.User) error {
	query := `
		INSERT INTO users (id, full_name, email, phone, password_hash, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`

	var id uuid.UUID
	var createdAt time.Time

	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}

	err := r.pool.QueryRow(
		ctx,
		query,
		user.ID,
		user.FullName,
		user.Email,
		user.Phone,
		user.PasswordHash,
		time.Now(),
	).Scan(&id, &createdAt)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("user creation failed: %w", err)
		}

		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return fmt.Errorf("user with this email already exists")
		}
		return fmt.Errorf("failed to create user: %w", err)
	}

	user.ID = id
	user.CreatedAt = createdAt
	return nil
}

func (r *UserRepositoryImpl) GetByEmail(ctx context.Context, email string) (*entity.User, error) {
	query := `
		SELECT id, full_name, email, phone, password_hash, created_at
		FROM users
		WHERE email = $1
	`

	user := &entity.User{}
	err := r.pool.QueryRow(ctx, query, email).Scan(
		&user.ID,
		&user.FullName,
		&user.Email,
		&user.Phone,
		&user.PasswordHash,
		&user.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) || errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found: %w", err)
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}

	return user, nil
}

func (r *UserRepositoryImpl) GetByID(ctx context.Context, id string) (*entity.User, error) {
	userID, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	query := `
		SELECT id, full_name, email, phone, password_hash, created_at
		FROM users
		WHERE id = $1
	`

	user := &entity.User{}
	err = r.pool.QueryRow(ctx, query, userID).Scan(
		&user.ID,
		&user.FullName,
		&user.Email,
		&user.Phone,
		&user.PasswordHash,
		&user.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) || errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found: %w", err)
		}
		return nil, fmt.Errorf("failed to get user by ID: %w", err)
	}

	return user, nil
}
