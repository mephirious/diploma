package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	paymentv1 "github.com/diploma/payment-svc/api/v1"
	"github.com/diploma/payment-svc/internal/adapters/inbound/grpc/handler"
	"github.com/diploma/payment-svc/internal/adapters/outbound/stripe"
	"github.com/diploma/payment-svc/internal/application/payment/usecase"
	"github.com/diploma/payment-svc/internal/config"
	"github.com/diploma/payment-svc/internal/domain/payment/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	stripeClient := stripe.NewStripeClient(cfg.StripeConfig.APIKey)

	paymentService := service.NewPaymentService(nil)

	startPaymentUseCase := usecase.NewStartPaymentForSessionUseCase(paymentService, stripeClient, nil)
	handleWebhookUseCase := usecase.NewHandleStripeWebhookUseCase(paymentService, nil)

	paymentHandler := handler.NewPaymentGRPCHandler(startPaymentUseCase, handleWebhookUseCase)

	grpcServer := grpc.NewServer()

	paymentv1.RegisterPaymentServiceServer(grpcServer, paymentHandler)

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
