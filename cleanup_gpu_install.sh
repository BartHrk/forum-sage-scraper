#!/bin/bash

# Cleanup script for removing GPU-based installation
echo "Stopping existing services..."
systemctl stop ollama || true
systemctl disable ollama || true

echo "Removing Ollama..."
rm -rf /usr/local/bin/ollama
rm -rf /usr/local/lib/ollama
rm -rf /etc/ollama
rm -rf /var/log/ollama

echo "Removing systemd service..."
rm -f /etc/systemd/system/ollama.service
systemctl daemon-reload

echo "Cleanup complete."