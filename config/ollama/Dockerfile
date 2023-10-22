# Stage 1: Build the binary
FROM golang:alpine AS builder

# Install required dependencies
RUN apk add --no-cache git build-base cmake

# Set the working directory within the container
WORKDIR /app

# Clone the source code from the GitHub repository
RUN git clone https://github.com/jmorganca/ollama.git .

# Build the binary with static linking
RUN go generate ./... \
    && go build -ldflags '-linkmode external -extldflags "-static"' -o .

# Stage 2: Create the final image
FROM alpine

ENV OLLAMA_HOST "0.0.0.0"

# Install required runtime dependencies
RUN apk add --no-cache libstdc++ curl

# Copy the custom entry point script into the container
COPY Modelfile /Modelfile

# Copy the custom entry point script into the container
COPY entrypoint.sh /entrypoint.sh

# Make the script executable
RUN chmod +x /entrypoint.sh

# Create a non-root user
ARG USER=ollama
ARG GROUP=ollama
RUN addgroup $GROUP && adduser -D -G $GROUP $USER

# Copy the binary from the builder stage
COPY --from=builder /app/ollama /bin/ollama

USER $USER:$GROUP

ENTRYPOINT ["/entrypoint.sh"]
