FROM python:3.9-slim

WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the script
COPY otel_test.py .

# Make script executable
RUN chmod +x otel_test.py

ENTRYPOINT ["python", "otel_test.py"]

