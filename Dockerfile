FROM python:3.11-slim

# CRITICAL FIX for ML libraries like dlib/OpenCV (which need C++ tools)
# Install system dependencies, and clean up the cache to keep the image small
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev && \
    rm -rf /var/lib/apt/lists/*

# ... rest of your Dockerfile ...

# Set workdir inside container
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy project code
COPY . .

# App will listen on port 5000 inside the container
EXPOSE 5000

# Start gunicorn using wsgi:application on port 5000
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "wsgi:application"]