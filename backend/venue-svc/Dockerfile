FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git make protobuf-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o venue-svc ./cmd/venue-svc

FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /root/

COPY --from=builder /app/venue-svc .

COPY --from=builder /app/scripts/migrations ./scripts/migrations

EXPOSE 50053

CMD ["./venue-svc"]

