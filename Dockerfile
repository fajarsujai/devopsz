################
# BUILD BINARY #
################
# Golang builder stage
FROM golang:1.20 as builder

#BUILD-ARG
ARG PORT
ARG PROJECT

# Install git, SSL ca certificates, and timezone data
RUN apt-get update && apt-get install -y git ca-certificates tzdata

# Install protobuf compiler
RUN apt-get install -y protobuf-compiler

# Set the working directory
WORKDIR /app

# Copy entire source code
COPY . .

# Remove go.mod and go.sum if they exist
RUN if [ -f go.mod ]; then rm go.mod; fi && if [ -f go.sum ]; then rm go.sum; fi

# Setup Golang Module and generated protoc
RUN go mod init bpay.com/${PROJECT}
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
RUN export PATH="$PATH:$(go env GOPATH)/bin"
RUN protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/*.proto
RUN go mod tidy

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /bin/app main.go

#####################
# MAKE SMALL BINARY #
#####################
# Final stage: lightweight container
FROM alpine:3.16

#Build-ARG
ARG PORT
ARG PROJECT

# Set the working directory
WORKDIR /app


#EXPOSE PORT
EXPOSE ${PORT}
# Copy necessary files from builder stage
COPY --from=builder /bin/app /bin/app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
# COPY .env /app/.env

# Set the entry point for the container
ENTRYPOINT ["/bin/app"]
