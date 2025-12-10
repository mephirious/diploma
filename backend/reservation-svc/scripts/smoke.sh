#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting smoke tests for reservation-svc...${NC}"

echo -e "${YELLOW}Step 1: Starting docker-compose services...${NC}"
docker-compose up -d --build

echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

echo -e "${YELLOW}Step 2: Waiting for PostgreSQL...${NC}"
RETRIES=30
until docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres, $((RETRIES--)) remaining attempts..."
  sleep 2
done

if [ $RETRIES -eq 0 ]; then
  echo -e "${RED}FAIL: PostgreSQL did not become ready${NC}"
  docker-compose down
  exit 1
fi

echo -e "${YELLOW}Step 3: Running database migrations...${NC}"
docker-compose exec -T postgres psql -U postgres -d auth < backend/reservation-svc/scripts/migrations/001_init.sql

if [ $? -ne 0 ]; then
  echo -e "${RED}FAIL: Migration failed${NC}"
  docker-compose down
  exit 1
fi

echo -e "${YELLOW}Step 4: Waiting for reservation-svc to be ready...${NC}"
RETRIES=30
sleep 5

echo -e "${YELLOW}Step 5: Testing CreateReservation with grpcurl...${NC}"

if ! command -v grpcurl &> /dev/null; then
  echo -e "${YELLOW}grpcurl not found. Installing...${NC}"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -L https://github.com/fullstorydev/grpcurl/releases/download/v1.8.9/grpcurl_1.8.9_linux_x86_64.tar.gz | tar -xz
    chmod +x grpcurl
    GRPCURL="./grpcurl"
  else
    echo -e "${RED}FAIL: grpcurl is required but not installed. Please install it manually.${NC}"
    docker-compose down
    exit 1
  fi
else
  GRPCURL="grpcurl"
fi

TEST_USER_ID="123e4567-e89b-12d3-a456-426614174000"
TEST_APARTMENT_ID="223e4567-e89b-12d3-a456-426614174001"

RESPONSE=$($GRPCURL -plaintext -d "{
  \"user_id\": \"$TEST_USER_ID\",
  \"apartment_id\": \"$TEST_APARTMENT_ID\",
  \"comment\": \"Test reservation\"
}" localhost:9092 reservation.v1.ReservationService/CreateReservation 2>&1) || true

if echo "$RESPONSE" | grep -q "reservation_id"; then
  RESERVATION_ID=$(echo "$RESPONSE" | grep -o '"reservation_id":"[^"]*"' | cut -d'"' -f4)
  echo -e "${GREEN}PASS: CreateReservation returned reservation_id: $RESERVATION_ID${NC}"
else
  echo -e "${RED}FAIL: CreateReservation did not return expected response${NC}"
  echo "Response: $RESPONSE"
  docker-compose down
  exit 1
fi

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}All smoke tests PASSED!${NC}"
echo -e "${GREEN}================================${NC}"

