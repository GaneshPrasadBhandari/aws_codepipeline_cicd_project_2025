#!/usr/bin/env bash
set -euo pipefail

# 1. Setup Deployment Directory and Permissions
# This must be done BEFORE the 'Install' phase to ensure the CodeDeploy
# agent has the right place and permissions to copy the files.
sudo mkdir -p /opt/mlproject
sudo chown -R ubuntu:ubuntu /opt/mlproject

# 2. Install Python Venv/Pip (OS-Level Packages)
# Check for apt (Ubuntu/Debian) and install the venv package
if command -v apt >/dev/null 2>&1; then
    sudo apt update -y || true
    # Install the OS-level packages needed for virtual environments and pip
    sudo apt install -y python3-venv python3-pip || true
# Install Python/Pip (RHEL/Amazon Linux)
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y || true
    sudo dnf install -y python3.10 python3.10-pip || true
# Fallback for older systems using yum
elif command -v yum >/dev/null 2>&1; then
    sudo yum update -y || true
    sudo yum install -y python3-pip || true
fi

# NOTE: Steps 3 and 4 from your original script MUST be moved to after_install.sh