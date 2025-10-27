#!/usr/bin/env bash
set -euo pipefail

# 1. Setup Deployment Directory and Permissions for Ubuntu
sudo mkdir -p /opt/mlproject
sudo chown -R ubuntu:ubuntu /opt/mlproject

# 2. Install Python Venv/Pip (Ubuntu-Specific)
# Check for apt and install the venv package if running on Ubuntu
if command -v apt >/dev/null 2>&1; then
    sudo apt update -y || true
    sudo apt install -y python3-venv python3-pip || true
# Install Python/Pip (AL2023 or AL2) - Keeping this for robustness
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y || true
    sudo dnf install -y python3.10 python3.10-pip || true
else
    sudo yum update -y || true
    sudo yum install -y python3-pip || true
fi

# 3. Create/refresh venv and install deps
cd /opt/mlproject
# Removed redundant path in pip install -r, as we are already CD'd into /opt/mlproject
python3 -m venv .venv || python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 4. Create (or update) systemd service for Gunicorn
sudo tee /etc/systemd/system/mlproject.service >/dev/null <<'EOF'
[Unit]
Description=Gunicorn for mlproject
After=network.target

[Service]
# CRITICAL FIX: User must be 'ubuntu' to match the chown command above
User=ubuntu
WorkingDirectory=/opt/mlproject
Environment="PATH=/opt/mlproject/.venv/bin"
ExecStart=/opt/mlproject/.venv/bin/gunicorn -w 2 -b 0.0.0.0:80 wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload