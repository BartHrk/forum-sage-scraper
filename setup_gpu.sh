#!/bin/bash

# GPU Configuration for NVIDIA GRID K2 (Dual GPU setup)
# Each GPU has 4GB VRAM

# Install required packages
apt-get update && apt-get install -y \
    nvidia-driver-535 \
    nvidia-utils-535 \
    nvidia-cuda-toolkit

# Configure GPU settings for GRID K2
nvidia-smi -pm 1  # Enable persistent mode

# Set specific configurations for each GPU in the GRID K2
nvidia-smi -i 0 -pl 130  # Power limit for first GPU
nvidia-smi -i 1 -pl 130  # Power limit for second GPU

# Set compute mode to exclusive process
nvidia-smi -i 0 -c 3
nvidia-smi -i 1 -c 3

# Memory configuration for Ollama
cat > /etc/ollama/config.yaml << EOF
gpu:
  devices:
    - 0  # First GPU
    - 1  # Second GPU
  memory: 3500  # Reserve 3.5GB per GPU for model
runner:
  model: "huihui_ai/command-r7b-abliterated"
server:
  host: "77.237.11.39"
  port: 11434
EOF

# Start Ollama service
systemctl restart ollama

# Create monitoring script for dual GPU setup
cat > /usr/local/bin/monitor-grid-k2.sh << 'EOF'
#!/bin/bash
LOG_DIR="/var/log/ollama"
mkdir -p $LOG_DIR

while true; do
    for i in 0 1; do
        nvidia-smi -i $i --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader >> "$LOG_DIR/gpu_${i}_metrics.log"
    done
    sleep 30
done
EOF

chmod +x /usr/local/bin/monitor-grid-k2.sh

# Start GPU monitoring
/usr/local/bin/monitor-grid-k2.sh &

echo "GPU setup completed. Ollama server running at http://77.237.11.39:5050"