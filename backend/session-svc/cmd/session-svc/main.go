package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	sessionv1 "github.com/diploma/session-svc/api/v1"
	"github.com/diploma/session-svc/internal/adapters/inbound/grpc/handler"
	"github.com/diploma/session-svc/internal/adapters/outbound/database/repository"
	"github.com/diploma/session-svc/internal/adapters/outbound/external/events"
	participantusecase "github.com/diploma/session-svc/internal/application/participant/usecase"
	sessionusecase "github.com/diploma/session-svc/internal/application/session/usecase"
	"github.com/diploma/session-svc/internal/config"
	participantservice "github.com/diploma/session-svc/internal/domain/participant/service"
	sessionservice "github.com/diploma/session-svc/internal/domain/session/service"
	"github.com/nats-io/nats.go"
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

	db, err := gorm.Open(postgres.Open(cfg.DBConfig.ConnectionString()), &gorm.Config{})
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

	natsConn, err := nats.Connect(cfg.NATSConfig.URL)
	if err != nil {
		log.Fatalf("Failed to connect to NATS: %v", err)
	}
	defer natsConn.Close()

	sessionRepo := repository.NewSessionRepository(db)
	participantRepo := repository.NewParticipantRepository(db)

	sessionService := sessionservice.NewSessionService(sessionRepo, participantRepo)
	participantService := participantservice.NewParticipantService(participantRepo)

	eventPublisher := events.NewNATSEventPublisher(natsConn)

	createSessionUseCase := sessionusecase.NewCreateSessionUseCase(sessionService, participantService, eventPublisher)
	getSessionUseCase := sessionusecase.NewGetSessionUseCase(sessionService)
	listOpenSessionsUseCase := sessionusecase.NewListOpenSessionsUseCase(sessionService)
	listUserSessionsUseCase := sessionusecase.NewListUserSessionsUseCase(sessionService)
	cancelSessionUseCase := sessionusecase.NewCancelSessionUseCase(sessionService, eventPublisher)

	joinSessionUseCase := participantusecase.NewJoinSessionUseCase(sessionService, participantService, eventPublisher)
	leaveSessionUseCase := participantusecase.NewLeaveSessionUseCase(sessionService, participantService, eventPublisher)
	listSessionParticipantsUseCase := participantusecase.NewListSessionParticipantsUseCase(participantService)

	sessionHandler := handler.NewSessionGRPCHandler(
		createSessionUseCase,
		getSessionUseCase,
		listOpenSessionsUseCase,
		listUserSessionsUseCase,
		cancelSessionUseCase,
		joinSessionUseCase,
		leaveSessionUseCase,
		listSessionParticipantsUseCase,
	)

	grpcServer := grpc.NewServer()

	sessionv1.RegisterSessionServiceServer(grpcServer, sessionHandler)

	reflection.Register(grpcServer)

	addr := fmt.Sprintf(":%s", cfg.GRPCPort)
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
