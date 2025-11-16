FROM python:3.11-slim

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
# (make sure you have wsgi.py with "application" object)
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "wsgi:application"]
