package dto

import "time"

type UserDTO struct {
	ID        string
	FullName  string
	Email     string
	Phone     string
	CreatedAt time.Time
}

type RegisterUserInput struct {
	FullName string
	Email    string
	Phone    string
	Password string
}

type RegisterUserOutput struct {
	UserID string
}

type LoginUserInput struct {
	Email    string
	Password string
}

type LoginUserOutput struct {
	AccessToken  string
	RefreshToken string
	UserID       string
}

type RefreshTokenInput struct {
	RefreshToken string
}

type RefreshTokenOutput struct {
	AccessToken  string
	RefreshToken string
}

type GetUserProfileInput struct {
	UserID string
}

type GetUserProfileOutput struct {
	User UserDTO
}
