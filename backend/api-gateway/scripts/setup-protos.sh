#!/bin/bash

set -e

echo "Setting up proto files for API Gateway..."

# Check if we're in the correct directory
if [ ! -d "api/proto" ]; then
    echo "Error: api/proto directory not found. Run from api-gateway root."
    exit 1
fi

# Copy proto files from backend services
echo "Copying proto files..."

cp ../auth-svc/api/v1/auth.proto api/proto/auth/v1/ 2>/dev/null || echo "Warning: auth.proto not found"
cp ../venue-svc/api/v1/venue.proto api/proto/venue/v1/ 2>/dev/null || echo "Warning: venue.proto not found"
cp ../reservation-svc/api/v1/reservation.proto api/proto/reservation/v1/ 2>/dev/null || echo "Warning: reservation.proto not found"
cp ../session-svc/api/v1/session.proto api/proto/session/v1/ 2>/dev/null || echo "Warning: session.proto not found"
cp ../payment-svc/api/v1/payment.proto api/proto/payment/v1/ 2>/dev/null || echo "Warning: payment.proto not found"

# Update go_package options
echo "Updating go_package options..."

# Auth
if [ -f "api/proto/auth/v1/auth.proto" ]; then
    sed -i 's|option go_package = .*|option go_package = "github.com/diploma/api-gateway/api/proto/auth/v1;authv1";|' api/proto/auth/v1/auth.proto
    echo "✓ Updated auth.proto"
fi

# Venue
if [ -f "api/proto/venue/v1/venue.proto" ]; then
    sed -i 's|option go_package = .*|option go_package = "github.com/diploma/api-gateway/api/proto/venue/v1;venuev1";|' api/proto/venue/v1/venue.proto
    echo "✓ Updated venue.proto"
fi

# Reservation
if [ -f "api/proto/reservation/v1/reservation.proto" ]; then
    sed -i 's|option go_package = .*|option go_package = "github.com/diploma/api-gateway/api/proto/reservation/v1;reservationv1";|' api/proto/reservation/v1/reservation.proto
    echo "✓ Updated reservation.proto"
fi

# Session
if [ -f "api/proto/session/v1/session.proto" ]; then
    sed -i 's|option go_package = .*|option go_package = "github.com/diploma/api-gateway/api/proto/session/v1;sessionv1";|' api/proto/session/v1/session.proto
    echo "✓ Updated session.proto"
fi

# Payment
if [ -f "api/proto/payment/v1/payment.proto" ]; then
    sed -i 's|option go_package = .*|option go_package = "github.com/diploma/api-gateway/api/proto/payment/v1;paymentv1";|' api/proto/payment/v1/payment.proto
    echo "✓ Updated payment.proto"
fi

echo ""
echo "Proto files setup complete!"
echo "Run 'make proto' to generate gRPC code."

