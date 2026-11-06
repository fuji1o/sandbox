FROM golang:1.23-alpine AS builder
 
WORKDIR /src
 
COPY go.mod go.sum* ./
RUN go mod download
 
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/app ./cmd/api 
FROM golang:1.23-alpine AS runtime
 
RUN addgroup -S sandbox && adduser -S -G sandbox sandbox
WORKDIR /app
COPY --from=builder --chown=sandbox:sandbox /out/app /app/app
 
USER sandbox
EXPOSE 8081
ENTRYPOINT ["/app/app"]