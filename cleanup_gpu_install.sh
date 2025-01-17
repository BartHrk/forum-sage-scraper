#!/bin/bash

# Cleanup script for removing GPU-based scraper installation
echo "Stopping existing services..."
systemctl stop ollama
systemctl disable ollama

echo "Removing GPU monitoring scripts..."
rm -f /usr/local/bin/monitor-grid-k2.sh
rm -rf /var/log/ollama/gpu_*_metrics.log

echo "Removing NVIDIA drivers and CUDA toolkit..."
apt-get remove -y nvidia-driver-535 nvidia-utils-535 nvidia-cuda-toolkit
apt-get autoremove -y

echo "Removing Ollama configuration..."
rm -rf /etc/ollama

echo "Cleanup complete."