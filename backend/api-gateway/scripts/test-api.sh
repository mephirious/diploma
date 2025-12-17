#!/bin/bash

# Simple API Gateway smoke test

set -e

API_URL="http://localhost:8080"

echo "Testing API Gateway endpoints..."
echo ""

# Health check
echo "1. Health check..."
curl -s "$API_URL/health" | grep -q "healthy" && echo "✓ Health check passed" || echo "✗ Health check failed"

# Try to register a user
echo ""
echo "2. Register user..."
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test_'$(date +%s)'@example.com",
    "phone": "1234567890",
    "password": "testpass123"
  }')

if echo "$REGISTER_RESPONSE" | grep -q "user_id"; then
    echo "✓ Registration successful"
    USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"user_id":"[^"]*"' | cut -d'"' -f4)
    echo "  User ID: $USER_ID"
else
    echo "✗ Registration failed"
    echo "  Response: $REGISTER_RESPONSE"
fi

# Try to login
echo ""
echo "3. Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }')

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo "✓ Login successful"
    ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo "  Token: ${ACCESS_TOKEN:0:20}..."
    
    # Test authenticated endpoint
    echo ""
    echo "4. Get profile (authenticated)..."
    PROFILE_RESPONSE=$(curl -s "$API_URL/api/v1/profile" \
      -H "Authorization: Bearer $ACCESS_TOKEN")
    
    if echo "$PROFILE_RESPONSE" | grep -q "user_id"; then
        echo "✓ Profile fetch successful"
    else
        echo "✗ Profile fetch failed"
        echo "  Response: $PROFILE_RESPONSE"
    fi
else
    echo "✗ Login failed"
    echo "  Response: $LOGIN_RESPONSE"
fi

# Test public endpoints
echo ""
echo "5. List venues (public)..."
VENUES_RESPONSE=$(curl -s "$API_URL/api/v1/venues?page=1&page_size=10")

if echo "$VENUES_RESPONSE" | grep -q "items"; then
    echo "✓ Venues list successful"
else
    echo "✗ Venues list failed"
    echo "  Response: $VENUES_RESPONSE"
fi

# Test open sessions
echo ""
echo "6. List open sessions (public)..."
SESSIONS_RESPONSE=$(curl -s "$API_URL/api/v1/sessions/open?page=1&page_size=10")

if echo "$SESSIONS_RESPONSE" | grep -q "sessions"; then
    echo "✓ Sessions list successful"
else
    echo "✗ Sessions list failed"
    echo "  Response: $SESSIONS_RESPONSE"
fi

echo ""
echo "API Gateway smoke test complete!"

