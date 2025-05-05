# Base stage for common setup
FROM python:3.12-slim as base

# Install system dependencies first
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY setup.py .
COPY microservices/ ./microservices/
RUN pip install -e .

# User Service
FROM base as user-service
ENV FLASK_APP=microservices.services.user
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]

# Movies Service
FROM base as movie-service
ENV FLASK_APP=microservices.services.movies
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]

# Showtimes Service
FROM base as showtime-service
ENV FLASK_APP=microservices.services.showtimes
CMD ["flask", "run", "--host=0.0.0.0", "--port=5002"]

# Bookings Service
FROM base as booking-service
ENV FLASK_APP=microservices.services.bookings
CMD ["flask", "run", "--host=0.0.0.0", "--port=5003"]