#!/usr/bin/env python3

from opentelemetry import trace, metrics
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter as OTLPSpanExporterGRPC
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter as OTLPSpanExporterHTTP
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.exporter.otlp.proto.grpc.metrics_exporter import OTLPMetricsExporter as OTLPMetricsExporterGRPC
from opentelemetry.exporter.otlp.proto.http.metrics_exporter import OTLPMetricsExporter as OTLPMetricsExporterHTTP
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
import argparse
import time
import sys
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def setup_tracing(protocol, endpoint):
    """Setup tracing with either gRPC or HTTP protocol"""
    if protocol == "grpc":
        span_exporter = OTLPSpanExporterGRPC(endpoint=endpoint)
    else:
        span_exporter = OTLPSpanExporterHTTP(endpoint=f"{endpoint}/v1/traces")
    
    trace_provider = TracerProvider()
    trace_provider.add_span_processor(BatchSpanProcessor(span_exporter))
    trace.set_tracer_provider(trace_provider)
    return trace.get_tracer(__name__)

def setup_metrics(protocol, endpoint):
    """Setup metrics with either gRPC or HTTP protocol"""
    if protocol == "grpc":
        metrics_exporter = OTLPMetricsExporterGRPC(endpoint=endpoint)
    else:
        metrics_exporter = OTLPMetricsExporterHTTP(endpoint=f"{endpoint}/v1/metrics")
    
    reader = PeriodicExportingMetricReader(metrics_exporter)
    provider = MeterProvider(metric_readers=[reader])
    metrics.set_meter_provider(provider)
    return metrics.get_meter(__name__)

def test_tracing(tracer):
    """Generate test spans"""
    with tracer.start_as_current_span("main_operation") as main_span:
        logger.info("Creating main span")
        time.sleep(1)  # Simulate some work
        
        with tracer.start_span("sub_operation") as sub_span:
            logger.info("Creating sub span")
            time.sleep(0.5)  # Simulate some work
            sub_span.set_attribute("custom.attribute", "test_value")

def test_metrics(meter):
    """Generate test metrics"""
    counter = meter.create_counter(
        name="test_counter",
        description="Test counter metric",
        unit="1"
    )
    
    # Create and record metrics
    counter.add(1, {"test.label": "test_value"})
    logger.info("Recorded test counter metric")

def main():
    parser = argparse.ArgumentParser(description='Test OpenTelemetry endpoints')
    parser.add_argument('--protocol', choices=['grpc', 'http'], required=True,
                      help='Protocol to use (grpc or http)')
    parser.add_argument('--host', required=True,
                      help='Host address (e.g., otel.yourdomain or otel-grpc.yourdomain)')
    parser.add_argument('--port', required=True,
                      help='Port number (e.g., 4317 for gRPC, 443 for HTTPS)')
    parser.add_argument('--secure', action='store_true',
                      help='Use HTTPS/TLS connection')
    
    args = parser.parse_args()
    
    # Construct endpoint URL
    scheme = "https" if args.secure else "http"
    if args.protocol == "grpc":
        endpoint = f"{args.host}:{args.port}"
    else:
        endpoint = f"{scheme}://{args.host}:{args.port}"

    try:
        logger.info(f"Testing {args.protocol.upper()} endpoint: {endpoint}")
        
        # Setup and test tracing
        tracer = setup_tracing(args.protocol, endpoint)
        test_tracing(tracer)
        logger.info("Tracing test completed")
        
        # Setup and test metrics
        meter = setup_metrics(args.protocol, endpoint)
        test_metrics(meter)
        logger.info("Metrics test completed")
        
        # Wait a bit for data to be exported
        time.sleep(5)
        logger.info("Test completed successfully")
        
    except Exception as e:
        logger.error(f"Error during testing: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
