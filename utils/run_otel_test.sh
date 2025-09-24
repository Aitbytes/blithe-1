#!/usr/bin/env bash

# Default values
PROTOCOL="http"
HOST="localhost"
PORT="4318"
SECURE=false

# Help function
function show_help {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --protocol   Protocol to use (grpc or http) [default: http]"
    echo "  --host      Host address [default: localhost]"
    echo "  --port      Port number [default: 4318]"
    echo "  --secure    Use HTTPS/TLS connection [default: false]"
    echo "  --help      Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --protocol)
            PROTOCOL="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --secure)
            SECURE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Build the Docker image
docker build -t otel-tester .

# Construct the command
CMD="docker run --rm otel-tester --protocol $PROTOCOL --host $HOST --port $PORT"
if [ "$SECURE" = true ]; then
    CMD="$CMD --secure"
fi

# Run the container
echo "Running OpenTelemetry test with: $CMD"
$CMD

