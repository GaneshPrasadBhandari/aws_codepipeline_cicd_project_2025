#!/usr/bin/env bash
set -euo pipefail

sudo mkdir -p /opt/mlproject
sudo chown -R ubuntu:ubuntu /opt/mlproject

# Install Python/Pip (AL2023 or AL2)
if command -v dnf >/dev/null 2>&1; then
  sudo dnf update -y || true
  sudo dnf install -y python3.10 python3.10-pip || true
else
  sudo yum update -y || true
  sudo yum install -y python3-pip || true
fi

# Create/refresh venv and install deps
cd /opt/mlproject
python3 -m venv .venv || python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
# Corrected path to the requirements file
pip install -r /opt/mlproject/requirements.txt

# Create (or update) systemd service for Gunicorn
sudo tee /etc/systemd/system/mlproject.service >/dev/null <<'EOF'
[Unit]
Description=Gunicorn for mlproject
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/mlproject
Environment="PATH=/opt/mlproject/.venv/bin"
ExecStart=/opt/mlproject/.venv/bin/gunicorn -w 2 -b 0.0.0.0:80 wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

