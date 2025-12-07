package entity

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID
	FullName     string
	Email        string
	Phone        string
	PasswordHash string
	CreatedAt    time.Time
}

func (u *User) IsValid() bool {
	return u.Email != "" && u.PasswordHash != ""
}
