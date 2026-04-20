# ## Parent image
# FROM python:3.10-slim

# ## Essential environment variables
# ENV PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# ## Work directory inside the docker container
# WORKDIR /app

# ## Installing system dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     curl \
#     && rm -rf /var/lib/apt/lists/*

# ## Copying all contents from local to container
# COPY . .

# ## Install Python dependencies
# RUN pip install --no-cache-dir -e .

# ## Expose only flask port
# EXPOSE 5000

# ## Run the Flask app
# CMD ["python", "app/application.py"]

FROM python:3.10-slim as builder

ENV PIP_DEFAULT_TIMEOUT=300 \
    PIP_RETRIES=10

WORKDIR /tmp

COPY requirements.txt .

# Download all packages to local cache
RUN pip download \
    --no-cache-dir \
    --default-timeout=300 \
    --retries 10 \
    -r requirements.txt \
    -d ./packages

# Final stage
FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-downloaded packages
COPY --from=builder /tmp/packages ./packages
COPY requirements.txt .

# Install from local packages (no network needed)
RUN pip install \
    --no-cache-dir \
    --no-index \
    --find-links ./packages \
    -r requirements.txt

# Copy application code
COPY . .

EXPOSE 5000

CMD ["python", "app/application.py"]

