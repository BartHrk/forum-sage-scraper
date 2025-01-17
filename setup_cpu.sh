#!/bin/bash

# Install required packages
apt-get update
apt-get install -y curl wget htop numactl

# Configure CPU governor for performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" > $cpu 2>/dev/null || true
done

# Configure system memory limits
cat > /etc/sysctl.d/99-memory.conf << EOF
vm.swappiness=10
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.vfs_cache_pressure=50
EOF

sysctl -p /etc/sysctl.d/99-memory.conf

# Create necessary directories
mkdir -p /etc/ollama
mkdir -p /var/log/ollama

# Install Ollama
curl https://ollama.ai/install.sh | sh

# Wait for Ollama binary to be available
sleep 5

# Configure Ollama for CPU optimization
cat > /etc/ollama/config.yaml << EOF
runner:
  model: "huihui_ai/phi4-abliterated:14b-q8_0"
  threads: 144
  parallel_requests: 8
server:
  host: "0.0.0.0"
  port: 11434
system:
  cpu_memory: 262144
EOF

# Create systemd service
cat > /etc/systemd/system/ollama.service << EOF
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
Restart=always
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_PORT=11434"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ollama
systemctl start ollama

# Wait for Ollama service to start
sleep 10

echo "CPU setup completed. Ollama server running at http://localhost:11434"