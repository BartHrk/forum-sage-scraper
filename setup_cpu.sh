#!/bin/bash

# CPU Configuration for Dual Xeon E5-2699V3 (36 cores/72 threads per CPU)
# Total RAM: 288GB DDR4 @ 2133MHz

# Install required packages
apt-get update && apt-get install -y \
    curl \
    wget \
    htop \
    numactl

# Configure CPU governor for performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" > $cpu
done

# Configure system memory limits
cat > /etc/sysctl.d/99-memory.conf << EOF
vm.swappiness=10
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.vfs_cache_pressure=50
EOF

sysctl -p /etc/sysctl.d/99-memory.conf

# Install Ollama
curl https://ollama.ai/install.sh | sh

# Configure Ollama for CPU optimization
mkdir -p /etc/ollama
cat > /etc/ollama/config.yaml << EOF
runner:
  model: "huihui_ai/command-r7b-abliterated"
  threads: 144  # Using all available threads
  parallel_requests: 8
server:
  host: "77.237.11.39"
  port: 11434
system:
  cpu_memory: 262144  # Allocate 256GB for model (leaving some for system)
EOF

# Create CPU monitoring script
cat > /usr/local/bin/monitor-cpu.sh << 'EOF'
#!/bin/bash
LOG_DIR="/var/log/ollama"
mkdir -p $LOG_DIR

while true; do
    mpstat -P ALL 1 1 >> "$LOG_DIR/cpu_metrics.log"
    free -m >> "$LOG_DIR/memory_metrics.log"
    sleep 30
done
EOF

chmod +x /usr/local/bin/monitor-cpu.sh

# Start Ollama service with CPU affinity
systemctl stop ollama
cat > /etc/systemd/system/ollama.service << EOF
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=numactl --interleave=all /usr/bin/ollama serve
Restart=always
Environment="OLLAMA_HOST=77.237.11.39"
Environment="OLLAMA_PORT=11434"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ollama
systemctl start ollama

# Start CPU monitoring
/usr/local/bin/monitor-cpu.sh &

echo "CPU setup completed. Ollama server running at http://77.237.11.39:4040"