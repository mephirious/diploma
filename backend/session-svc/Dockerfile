FROM golang:1.24-alpine AS builder

WORKDIR /build

RUN apk add --no-cache git make protobuf protobuf-dev

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN if [ -d "api" ]; then \
      go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
      go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
      find api -name "*.proto" -exec protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative {} \; || true; \
    fi

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o session-svc ./cmd/session-svc

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=builder /build/session-svc /app/session-svc

EXPOSE 50054

ENTRYPOINT ["/app/session-svc"]

