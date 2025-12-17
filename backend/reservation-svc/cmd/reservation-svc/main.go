package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	reservationv1 "github.com/diploma/reservation-svc/api/v1"
	"github.com/diploma/reservation-svc/internal/adapters/inbound/grpc/handler"
	"github.com/diploma/reservation-svc/internal/adapters/outbound/database/repository"
	"github.com/diploma/reservation-svc/internal/adapters/outbound/external/events"
	"github.com/diploma/reservation-svc/internal/application/reservation/usecase"
	"github.com/diploma/reservation-svc/internal/config"
	"github.com/diploma/reservation-svc/internal/domain/reservation/service"
	"github.com/nats-io/nats.go"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/jaeger"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	tracesdk "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	if cfg.Jaeger.Enabled {
		if err := initTracing(cfg.Jaeger.URL); err != nil {
			log.Printf("Warning: Failed to initialize tracing: %v", err)
		}
	}

	db, err := gorm.Open(postgres.Open(cfg.Database.URL), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		log.Fatalf("Failed to get database instance: %v", err)
	}
	defer sqlDB.Close()

	if err := sqlDB.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	natsConn, err := nats.Connect(cfg.NATS.URL, nats.Timeout(cfg.NATS.Timeout))
	if err != nil {
		log.Fatalf("Failed to connect to NATS: %v", err)
	}
	defer natsConn.Close()

	reservationRepo := repository.NewReservationRepository(db)
	reservationService := service.NewReservationService(reservationRepo)

	eventPublisher := events.NewNATSPublisher(natsConn)

	createReservationUseCase := usecase.NewCreateReservationUseCase(reservationService, eventPublisher)
	confirmReservationUseCase := usecase.NewConfirmReservationUseCase(reservationService, eventPublisher)
	cancelReservationUseCase := usecase.NewCancelReservationUseCase(reservationService, eventPublisher)
	getReservationUseCase := usecase.NewGetReservationUseCase(reservationService)
	listReservationsByUserUseCase := usecase.NewListReservationsByUserUseCase(reservationService)

	reservationHandler := handler.NewReservationGRPCHandler(
		createReservationUseCase,
		confirmReservationUseCase,
		cancelReservationUseCase,
		getReservationUseCase,
		listReservationsByUserUseCase,
	)

	var serverOpts []grpc.ServerOption

	if cfg.Jaeger.Enabled {
		serverOpts = []grpc.ServerOption{
			grpc.ChainUnaryInterceptor(
				otelgrpc.UnaryServerInterceptor(),
			),
			grpc.StreamInterceptor(otelgrpc.StreamServerInterceptor()),
		}
	}

	grpcServer := grpc.NewServer(serverOpts...)

	reservationv1.RegisterReservationServiceServer(grpcServer, reservationHandler)

	reflection.Register(grpcServer)

	addr := fmt.Sprintf(":%s", cfg.Server.GRPCPort)
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("Failed to listen on %s: %v", addr, err)
	}

	log.Printf("Starting gRPC server on %s", addr)

	go func() {
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("Failed to serve: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	grpcServer.GracefulStop()
	log.Println("Server stopped")
}

func initTracing(jaegerURL string) error {
	exp, err := jaeger.New(jaeger.WithCollectorEndpoint(jaeger.WithEndpoint(jaegerURL)))
	if err != nil {
		return fmt.Errorf("failed to create Jaeger exporter: %w", err)
	}

	tp := tracesdk.NewTracerProvider(
		tracesdk.WithBatcher(exp),
		tracesdk.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("reservation-svc"),
		)),
	)

	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	return nil
}
