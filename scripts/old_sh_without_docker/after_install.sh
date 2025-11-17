#!/usr/bin/env bash
set -euo pipefail

# 1. Application Setup (requires files from the 'Install' phase)
cd /opt/mlproject

# Create/refresh venv and install deps
# The 'python3-venv' package was installed in before_install.sh
python3 -m venv .venv || python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 2. Create (or update) systemd service for Gunicorn
# This creates the service file which relies on the venv created above
sudo tee /etc/systemd/system/mlproject.service >/dev/null <<'EOF'
[Unit]
Description=Gunicorn for mlproject
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/mlproject
# Ensure the PATH points to the correct virtual environment location
Environment="PATH=/opt/mlproject/.venv/bin"
ExecStart=/opt/mlproject/.venv/bin/gunicorn -w 2 -b 0.0.0.0:80 wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service file
sudo systemctl daemon-reload