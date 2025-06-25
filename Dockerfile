# Build-Stage
FROM golang:1.24-alpine AS build
WORKDIR /app

# Copy the source code
COPY . .

# Install build dependencies
RUN apk add --no-cache gcc musl-dev curl

# Install templ
RUN go install github.com/a-h/templ/cmd/templ@latest

RUN curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64-musl

RUN chmod +x tailwindcss-linux-x64-musl

RUN ./tailwindcss-linux-x64-musl -i ./assets/css/input.css -o ./assets/css/output.css

# Generate templ files
RUN templ generate

RUN ls -l assets/css

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./main.go

# Deploy-Stage
FROM alpine:3.20.2
WORKDIR /app

# Install ca-certificates
RUN apk add --no-cache ca-certificates

# Set environment variable for runtime
ENV GO_ENV=production

# Copy the binary from the build stage
COPY --from=build /app/main .

# Expose the port your application runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]