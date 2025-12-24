# ---- stage 1: build dependencies ----
FROM python:3.12-slim AS builder

WORKDIR /app
COPY src/requirements.txt .

# Install deps into a separate folder we can copy later
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- stage 2: runtime image ----
FROM python:3.12-slim

WORKDIR /app

# Copy installed python packages from builder
COPY --from=builder /install /usr/local

# Copy app code
COPY src/ .

# Healthcheck needs curl
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fs http://localhost:5000/health || exit 1

CMD ["python", "app.py"]

