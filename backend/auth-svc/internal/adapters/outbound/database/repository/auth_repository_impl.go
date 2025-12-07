package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/diploma/auth-svc/internal/domain/auth/entity"
	"github.com/diploma/auth-svc/internal/domain/auth/port"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type AuthRepositoryImpl struct {
	pool *pgxpool.Pool
}

func NewAuthRepositoryImpl(pool *pgxpool.Pool) port.AuthRepository {
	return &AuthRepositoryImpl{
		pool: pool,
	}
}

func (r *AuthRepositoryImpl) SaveRefreshToken(ctx context.Context, token *entity.Token) error {
	query := `
		INSERT INTO user_tokens (id, user_id, refresh_token, created_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at
	`

	var id uuid.UUID
	var createdAt time.Time

	if token.ID == uuid.Nil {
		token.ID = uuid.New()
	}

	err := r.pool.QueryRow(
		ctx,
		query,
		token.ID,
		token.UserID,
		token.RefreshToken,
		time.Now(),
	).Scan(&id, &createdAt)

	if err != nil {
		return fmt.Errorf("failed to save refresh token: %w", err)
	}

	token.ID = id
	token.CreatedAt = createdAt
	return nil
}

func (r *AuthRepositoryImpl) GetRefreshToken(ctx context.Context, refreshToken string) (*entity.Token, error) {
	query := `
		SELECT id, user_id, refresh_token, created_at
		FROM user_tokens
		WHERE refresh_token = $1
	`

	token := &entity.Token{}
	err := r.pool.QueryRow(ctx, query, refreshToken).Scan(
		&token.ID,
		&token.UserID,
		&token.RefreshToken,
		&token.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) || errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("refresh token not found: %w", err)
		}
		return nil, fmt.Errorf("failed to get refresh token: %w", err)
	}

	return token, nil
}

func (r *AuthRepositoryImpl) DeleteRefreshToken(ctx context.Context, refreshToken string) error {
	query := `
		DELETE FROM user_tokens
		WHERE refresh_token = $1
	`

	result, err := r.pool.Exec(ctx, query, refreshToken)
	if err != nil {
		return fmt.Errorf("failed to delete refresh token: %w", err)
	}

	if result.RowsAffected() == 0 {
		return fmt.Errorf("refresh token not found")
	}

	return nil
}
