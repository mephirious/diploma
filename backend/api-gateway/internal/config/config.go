package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port                   string
	AuthServiceURL         string
	VenueServiceURL        string
	ReservationServiceURL  string
	SessionServiceURL      string
	PaymentServiceURL      string
	NotificationServiceURL string
	Environment            string
	LogLevel               string
}

func Load() *Config {
	return &Config{
		Port:                   getEnv("PORT", "8080"),
		AuthServiceURL:         getEnv("AUTH_SERVICE_URL", "localhost:50051"),
		VenueServiceURL:        getEnv("VENUE_SERVICE_URL", "localhost:50053"),
		ReservationServiceURL:  getEnv("RESERVATION_SERVICE_URL", "localhost:50052"),
		SessionServiceURL:      getEnv("SESSION_SERVICE_URL", "localhost:50054"),
		PaymentServiceURL:      getEnv("PAYMENT_SERVICE_URL", "localhost:50055"),
		NotificationServiceURL: getEnv("NOTIFICATION_SERVICE_URL", "localhost:50056"),
		Environment:            getEnv("ENVIRONMENT", "development"),
		LogLevel:               getEnv("LOG_LEVEL", "info"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

