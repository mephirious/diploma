# How to Restart Services with Updates

## Backend Changes Made:

✅ **auth-svc**:
- `api/v1/auth.proto` - Added `user_id` to LoginResponse  
- `internal/application/user/dto/user_dto.go` - Added UserID field
- `internal/application/user/usecase/login_user.go` - Returns UserID
- `internal/adapters/inbound/grpc/handler/auth_grpc.go` - Passes UserID

✅ **api-gateway**:
- `internal/handler/auth_handler.go` - Already configured to pass UserID

## To Apply Changes:

### Option 1: Use Docker Compose (Recommended)

```bash
cd ~/Diploma/diploma

# Stop all services
docker-compose down

# Rebuild services
docker-compose build auth-svc api-gateway

# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f auth-svc
docker-compose logs -f api-gateway
```

### Option 2: Manual Docker Commands

```bash
cd ~/Diploma/diploma

# Build auth-svc
cd backend/auth-svc
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       api/v1/auth.proto
docker build -t diploma-auth-svc .
cd ../..

# Build api-gateway  
cd backend/api-gateway
docker build -t diploma-api-gateway .
cd ../..

# Stop old containers
docker stop auth-svc api-gateway
docker rm auth-svc api-gateway

# Start new containers
docker run -d --name auth-svc \
  --network diploma_default \
  -p 50051:50051 \
  -e DB_HOST=diploma-postgres \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_NAME=diploma \
  -e DB_SSL_MODE=disable \
  -e JWT_SECRET=your-secret-key-min-32-chars-long \
  -e JWT_ACCESS_TOKEN_TTL=15m \
  -e JWT_REFRESH_TOKEN_TTL=168h \
  -e JWT_ISSUER=auth-svc \
  diploma-auth-svc

docker run -d --name api-gateway \
  --network diploma_default \
  -p 8080:8080 \
  -e AUTH_SERVICE_URL=auth-svc:50051 \
  -e VENUE_SERVICE_URL=venue-svc:50053 \
  -e RESERVATION_SERVICE_URL=reservation-svc:50052 \
  -e SESSION_SERVICE_URL=session-svc:50054 \
  -e PAYMENT_SERVICE_URL=payment-svc:50055 \
  diploma-api-gateway
```

### Option 3: Use Flutter Workaround (Temporary)

The Flutter app has been updated to extract `user_id` from the JWT token if it's not in the response. This works without rebuilding backend!

Just hot reload your Flutter app:
```bash
# In Flutter terminal, press 'r'
```

## Test the Changes:

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nurs@test.com","password":"123123"}'
```

Expected response:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "...",
  "user_id": "5effbe2c-cbe5-4caa-8fe6-def32e6b954c"
}
```

## Current Status:

- ✅ Code changes complete
- ⚠️ Services need rebuild
- ✅ Flutter workaround active (extracts user_id from JWT)

## Recommendation:

**Use Option 3 (Flutter workaround) for now** - it works without rebuilding!

The backend code is ready for future deployments with proper `user_id` in response.

