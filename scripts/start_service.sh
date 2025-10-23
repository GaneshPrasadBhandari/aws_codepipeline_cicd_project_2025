#!/usr/bin/env bash
set -euo pipefail
sudo systemctl enable mlproject.service
sudo systemctl restart mlproject.service
sleep 2
sudo systemctl status mlproject.service --no-pager || true
