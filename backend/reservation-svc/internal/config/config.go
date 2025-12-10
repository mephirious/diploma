package config

import (
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Database DatabaseConfig
	NATS     NATSConfig
	Jaeger   JaegerConfig
	Server   ServerConfig
}

type DatabaseConfig struct {
	URL             string
	MaxConnections  int
	MaxIdleTime     time.Duration
	ConnMaxLifetime time.Duration
}

type NATSConfig struct {
	URL     string
	Timeout time.Duration
}

type JaegerConfig struct {
	URL     string
	Enabled bool
}

type ServerConfig struct {
	GRPCPort string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	cfg := &Config{
		Database: DatabaseConfig{
			URL:             getEnv("DATABASE_URL", "postgres://postgres:postgres@postgres:5432/auth?sslmode=disable"),
			MaxConnections:  getEnvAsInt("DB_MAX_CONNECTIONS", 25),
			MaxIdleTime:     getEnvAsDuration("DB_MAX_IDLE_TIME", 5*time.Minute),
			ConnMaxLifetime: getEnvAsDuration("DB_CONN_MAX_LIFETIME", 1*time.Hour),
		},
		NATS: NATSConfig{
			URL:     getEnv("NATS_URL", "nats://localhost:4222"),
			Timeout: getEnvAsDuration("NATS_TIMEOUT", 5*time.Second),
		},
		Jaeger: JaegerConfig{
			URL:     getEnv("JAEGER_URL", "http://localhost:14268/api/traces"),
			Enabled: getEnvAsBool("JAEGER_ENABLED", true),
		},
		Server: ServerConfig{
			GRPCPort: getEnv("GRPC_PORT", "9092"),
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

func getEnvAsInt(key string, defaultValue int) int {
	valueStr := os.Getenv(key)
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	valueStr := os.Getenv(key)
	if value, err := strconv.ParseBool(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
	valueStr := os.Getenv(key)
	if value, err := time.ParseDuration(valueStr); err == nil {
		return value
	}
	return defaultValue
}

