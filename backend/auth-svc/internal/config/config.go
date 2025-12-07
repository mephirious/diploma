package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Database DatabaseConfig
	Redis    RedisConfig
	NATS     NATSConfig
	Jaeger   JaegerConfig
	JWT      JWTConfig
	Server   ServerConfig
}

type DatabaseConfig struct {
	URL             string
	MaxConnections  int
	MaxIdleTime     time.Duration
	ConnMaxLifetime time.Duration
}

type RedisConfig struct {
	Addr         string
	Password     string
	DB           int
	DialTimeout  time.Duration
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
}

type NATSConfig struct {
	URL     string
	Timeout time.Duration
}

type JaegerConfig struct {
	URL     string
	Enabled bool
}

type JWTConfig struct {
	Secret          string
	AccessTokenTTL  time.Duration
	RefreshTokenTTL time.Duration
	Issuer          string
}

type ServerConfig struct {
	GRPCPort string
}

func Load() (*Config, error) {

	_ = godotenv.Load()

	cfg := &Config{
		Database: DatabaseConfig{
			URL:             getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5433/auth?sslmode=disable"),
			MaxConnections:  getEnvAsInt("DB_MAX_CONNECTIONS", 25),
			MaxIdleTime:     getEnvAsDuration("DB_MAX_IDLE_TIME", 5*time.Minute),
			ConnMaxLifetime: getEnvAsDuration("DB_CONN_MAX_LIFETIME", 1*time.Hour),
		},
		Redis: RedisConfig{
			Addr:         getEnv("REDIS_ADDR", "localhost:6379"),
			Password:     getEnv("REDIS_PASSWORD", ""),
			DB:           getEnvAsInt("REDIS_DB", 0),
			DialTimeout:  getEnvAsDuration("REDIS_DIAL_TIMEOUT", 5*time.Second),
			ReadTimeout:  getEnvAsDuration("REDIS_READ_TIMEOUT", 3*time.Second),
			WriteTimeout: getEnvAsDuration("REDIS_WRITE_TIMEOUT", 3*time.Second),
		},
		NATS: NATSConfig{
			URL:     getEnv("NATS_URL", "nats://localhost:4222"),
			Timeout: getEnvAsDuration("NATS_TIMEOUT", 5*time.Second),
		},
		Jaeger: JaegerConfig{
			URL:     getEnv("JAEGER_URL", "http://localhost:14268/api/traces"),
			Enabled: getEnvAsBool("JAEGER_ENABLED", true),
		},
		JWT: JWTConfig{
			Secret:          getEnv("JWT_SECRET", "supersecret_placeholder"),
			AccessTokenTTL:  getEnvAsDuration("JWT_ACCESS_TTL", 15*time.Minute),
			RefreshTokenTTL: getEnvAsDuration("JWT_REFRESH_TTL", 7*24*time.Hour),
			Issuer:          getEnv("JWT_ISSUER", "auth-svc"),
		},
		Server: ServerConfig{
			GRPCPort: getEnv("GRPC_PORT", "9091"),
		},
	}

	if cfg.JWT.Secret == "" {
		return nil, fmt.Errorf("JWT_SECRET must be set")
	}

	if cfg.JWT.Secret == "supersecret_placeholder" {
		fmt.Fprintf(os.Stderr, "WARNING: Using placeholder JWT_SECRET. This should NEVER be used in production!\n")
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
