package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	GRPCPort      string
	DBConfig      DatabaseConfig
	NATSConfig    NATSConfig
	StripeConfig  StripeConfig
}

type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

type NATSConfig struct {
	URL string
}

type StripeConfig struct {
	APIKey         string
	WebhookSecret  string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	cfg := &Config{
		GRPCPort: getEnv("GRPC_PORT", "50055"),
		DBConfig: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", "postgres"),
			DBName:   getEnv("DB_NAME", "payment_db"),
			SSLMode:  getEnv("DB_SSL_MODE", "disable"),
		},
		NATSConfig: NATSConfig{
			URL: getEnv("NATS_URL", "nats://localhost:4222"),
		},
		StripeConfig: StripeConfig{
			APIKey:        getEnv("STRIPE_API_KEY", ""),
			WebhookSecret: getEnv("STRIPE_WEBHOOK_SECRET", ""),
		},
	}

	return cfg, nil
}

func (c *DatabaseConfig) ConnectionString() string {
	return fmt.Sprintf(
		"postgres://%s:%s@%s:%s/%s?sslmode=%s",
		c.User,
		c.Password,
		c.Host,
		c.Port,
		c.DBName,
		c.SSLMode,
	)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

