package config

import (
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	NATSConfig NATSConfig
	SMTPConfig SMTPConfig
}

type NATSConfig struct {
	URL string
}

type SMTPConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	From     string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	cfg := &Config{
		NATSConfig: NATSConfig{
			URL: getEnv("NATS_URL", "nats://localhost:4222"),
		},
		SMTPConfig: SMTPConfig{
			Host:     getEnv("SMTP_HOST", "stub"), // Default to stub for development
			Port:     getEnv("SMTP_PORT", "587"),
			Username: getEnv("SMTP_USERNAME", ""),
			Password: getEnv("SMTP_PASSWORD", ""),
			From:     getEnv("SMTP_FROM", "notifications@sportsapp.com"),
		},
	}

	return cfg, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

