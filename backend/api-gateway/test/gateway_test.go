package test

import (
	"encoding/json"
	"testing"
)

type RegisterRequest struct {
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func TestRegisterRequestJSON(t *testing.T) {
	req := RegisterRequest{
		FullName: "John Doe",
		Email:    "john@example.com",
		Phone:    "+1234567890",
		Password: "SecurePass123",
	}

	data, err := json.Marshal(req)
	if err != nil {
		t.Fatalf("Failed to marshal JSON: %v", err)
	}

	var decoded RegisterRequest
	err = json.Unmarshal(data, &decoded)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON: %v", err)
	}

	if decoded.Email != req.Email {
		t.Errorf("Expected email %s, got %s", req.Email, decoded.Email)
	}
}

func TestLoginRequestJSON(t *testing.T) {
	req := LoginRequest{
		Email:    "john@example.com",
		Password: "SecurePass123",
	}

	data, err := json.Marshal(req)
	if err != nil {
		t.Fatalf("Failed to marshal JSON: %v", err)
	}

	var decoded LoginRequest
	err = json.Unmarshal(data, &decoded)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON: %v", err)
	}

	if decoded.Email != req.Email {
		t.Errorf("Expected email %s, got %s", req.Email, decoded.Email)
	}
}

func TestJSONValidation(t *testing.T) {
	tests := []struct {
		name    string
		json    string
		wantErr bool
	}{
		{
			name:    "Valid JSON",
			json:    `{"email":"test@example.com","password":"pass123"}`,
			wantErr: false,
		},
		{
			name:    "Invalid JSON",
			json:    `{"email":"test@example.com",`,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var req LoginRequest
			err := json.Unmarshal([]byte(tt.json), &req)
			if tt.wantErr && err == nil {
				t.Error("Expected error but got none")
			}
			if !tt.wantErr && err != nil {
				t.Errorf("Expected no error but got: %v", err)
			}
		})
	}
}

