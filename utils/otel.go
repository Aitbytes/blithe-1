package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/metric"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
)

var logger = log.New(os.Stdout, "", log.LstdFlags)

func setupTracing(ctx context.Context, protocol, endpoint string) (trace.Tracer, error) {
	var exporter sdktrace.SpanExporter
	var err error

	if protocol == "grpc" {
		conn, err := grpc.DialContext(ctx, endpoint, grpc.WithInsecure())
		if err != nil {
			return nil, fmt.Errorf("failed to create gRPC connection: %v", err)
		}
		exporter, err = otlptracegrpc.New(ctx, otlptracegrpc.WithGRPCConn(conn))
	} else {
		endpoint = fmt.Sprintf("%s/v1/traces", endpoint)
		exporter, err = otlptracehttp.New(ctx,
			otlptracehttp.WithEndpoint(endpoint),
			otlptracehttp.WithInsecure(),
		)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to create trace exporter: %v", err)
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName("otel-test"),
		),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create resource: %v", err)
	}

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tracerProvider)

	return tracerProvider.Tracer("otel-test"), nil
}

func setupMetrics(ctx context.Context, protocol, endpoint string) (metric.Meter, error) {
	var exporter sdkmetric.Exporter
	var err error

	if protocol == "grpc" {
		conn, err := grpc.DialContext(ctx, endpoint, grpc.WithInsecure())
		if err != nil {
			return nil, fmt.Errorf("failed to create gRPC connection: %v", err)
		}
		exporter, err = otlpmetricgrpc.New(ctx, otlpmetricgrpc.WithGRPCConn(conn))
	} else {
		// For HTTP, we should only pass the host:port as endpoint
		// The path will be automatically appended by the exporter
		exporter, err = otlpmetrichttp.New(ctx,
			otlpmetrichttp.WithEndpoint(endpoint),
			otlpmetrichttp.WithInsecure(),
		)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to create metric exporter: %v", err)
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName("otel-test"),
		),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create resource: %v", err)
	}

	meterProvider := sdkmetric.NewMeterProvider(
		sdkmetric.WithReader(sdkmetric.NewPeriodicReader(exporter)),
		sdkmetric.WithResource(res),
	)
	otel.SetMeterProvider(meterProvider)

	return meterProvider.Meter("otel-test"), nil
}

func testTracing(ctx context.Context, tracer trace.Tracer) {
	ctx, mainSpan := tracer.Start(ctx, "main_operation")
	logger.Println("Creating main span")
	time.Sleep(time.Second)

	_, subSpan := tracer.Start(ctx, "sub_operation")
	logger.Println("Creating sub span")
	time.Sleep(500 * time.Millisecond)
	subSpan.SetAttributes(attribute.String("custom.attribute", "test_value"))
	subSpan.End()

	mainSpan.End()
}

func testMetrics(ctx context.Context, meter metric.Meter) error {
	counter, err := meter.Int64Counter(
		"test_counter",
		metric.WithDescription("Test counter metric"),
		metric.WithUnit("1"),
	)
	if err != nil {
		return fmt.Errorf("failed to create counter: %v", err)
	}

	counter.Add(ctx, 1,
		metric.WithAttributes(attribute.String("test.label", "test_value")),
	)
	logger.Println("Recorded test counter metric")
	return nil
}

func main() {
	protocol := flag.String("protocol", "", "Protocol to use (grpc or http)")
	host := flag.String("host", "", "Host address")
	port := flag.String("port", "", "Port number")
	secure := flag.Bool("secure", false, "Use HTTPS/TLS connection")
	flag.Parse()

	if *protocol == "" || *host == "" || *port == "" {
		flag.Usage()
		os.Exit(1)
	}

	if *protocol != "grpc" && *protocol != "http" {
		logger.Fatal("Protocol must be either 'grpc' or 'http'")
	}

	var endpoint string
	if *protocol == "grpc" {
		endpoint = fmt.Sprintf("%s:%s", *host, *port)
	} else {
		scheme := "http"
		if *secure {
			scheme = "https"
		}
		endpoint = fmt.Sprintf("%s://%s:%s", scheme, *host, *port)
	}

	ctx := context.Background()
	logger.Printf("Testing %s endpoint: %s", *protocol, endpoint)

	tracer, err := setupTracing(ctx, *protocol, endpoint)
	if err != nil {
		logger.Fatalf("Failed to setup tracing: %v", err)
	}
	testTracing(ctx, tracer)
	logger.Println("Tracing test completed")

	meter, err := setupMetrics(ctx, *protocol, endpoint)
	if err != nil {
		logger.Fatalf("Failed to setup metrics: %v", err)
	}
	if err := testMetrics(ctx, meter); err != nil {
		logger.Fatalf("Failed to test metrics: %v", err)
	}
	logger.Println("Metrics test completed")

	// Wait for data to be exported
	time.Sleep(5 * time.Second)
	logger.Println("Test completed successfully")
}

