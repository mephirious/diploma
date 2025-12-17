#!/bin/bash
# Smoke test for venue-svc

set -e

HOST="${GRPC_HOST:-localhost}"
PORT="${GRPC_PORT:-50053}"
ENDPOINT="$HOST:$PORT"

echo "Running smoke tests for venue-svc at $ENDPOINT..."

# Test 1: Create a venue
echo "Test 1: Creating a venue..."
VENUE_RESPONSE=$(grpcurl -plaintext -d '{
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "City Sports Complex",
  "description": "Premium sports facility",
  "city": "New York",
  "address": "123 Sports Avenue",
  "latitude": 40.7128,
  "longitude": -74.0060
}' $ENDPOINT venue.v1.VenueService/CreateVenue)

VENUE_ID=$(echo $VENUE_RESPONSE | jq -r '.venueId')
echo "✓ Created venue with ID: $VENUE_ID"

# Test 2: Get venue
echo "Test 2: Getting venue..."
grpcurl -plaintext -d "{\"venue_id\": \"$VENUE_ID\"}" $ENDPOINT venue.v1.VenueService/GetVenue > /dev/null
echo "✓ Retrieved venue successfully"

# Test 3: List venues
echo "Test 3: Listing venues..."
grpcurl -plaintext -d '{"city": "New York", "page": 1, "page_size": 10}' $ENDPOINT venue.v1.VenueService/ListVenues > /dev/null
echo "✓ Listed venues successfully"

# Test 4: Create a resource
echo "Test 4: Creating a resource..."
RESOURCE_RESPONSE=$(grpcurl -plaintext -d "{
  \"venue_id\": \"$VENUE_ID\",
  \"name\": \"Tennis Court 1\",
  \"sport_type\": \"tennis\",
  \"capacity\": 4,
  \"surface_type\": \"hardcourt\",
  \"is_active\": true
}" $ENDPOINT venue.v1.VenueService/CreateResource)

RESOURCE_ID=$(echo $RESOURCE_RESPONSE | jq -r '.resourceId')
echo "✓ Created resource with ID: $RESOURCE_ID"

# Test 5: List resources by venue
echo "Test 5: Listing resources by venue..."
grpcurl -plaintext -d "{\"venue_id\": \"$VENUE_ID\", \"active_only\": true}" $ENDPOINT venue.v1.VenueService/ListResourcesByVenue > /dev/null
echo "✓ Listed resources successfully"

# Test 6: Set resource schedule
echo "Test 6: Setting resource schedule..."
grpcurl -plaintext -d "{
  \"resource_id\": \"$RESOURCE_ID\",
  \"slots\": [
    {
      \"day_of_week\": 1,
      \"start_time\": \"09:00\",
      \"end_time\": \"12:00\",
      \"base_price\": 50.0
    },
    {
      \"day_of_week\": 1,
      \"start_time\": \"13:00\",
      \"end_time\": \"18:00\",
      \"base_price\": 75.0
    }
  ]
}" $ENDPOINT venue.v1.VenueService/SetResourceSchedule > /dev/null
echo "✓ Set schedule successfully"

# Test 7: Get resource schedule
echo "Test 7: Getting resource schedule..."
grpcurl -plaintext -d "{\"resource_id\": \"$RESOURCE_ID\"}" $ENDPOINT venue.v1.VenueService/GetResourceSchedule > /dev/null
echo "✓ Retrieved schedule successfully"

echo ""
echo "✅ All smoke tests passed!"

