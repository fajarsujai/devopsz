################
# BUILD BINARY #
################
# Golang builder stage
FROM golang:1.20 as builder

# Install git, SSL ca certificates, and timezone data
RUN apt-get update && apt-get install -y git ca-certificates tzdata

# Set the working directory
WORKDIR /app

# Copy Go module files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /bin/app main.go

#####################
# MAKE SMALL BINARY #
#####################
# Final stage: lightweight container
FROM alpine:3.16

# Set the working directory
WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /bin/app /bin/app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY .env /app/.env
COPY data/termsAndCondition/termsAndConditionIDN.txt /app/data/termsAndCondition/termsAndConditionIDN.txt
COPY data/termsAndCondition/termsAndConditionEN.txt /app/data/termsAndCondition/termsAndConditionEN.txt

# Set the entry point for the container
ENTRYPOINT ["/bin/app"]
