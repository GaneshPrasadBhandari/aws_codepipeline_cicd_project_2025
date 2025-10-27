#!/usr/bin/env bash
set -euo pipefail

cd /opt/mlproject
# Use python3 to ensure the correct version is called
python3 -m venv .venv || python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt