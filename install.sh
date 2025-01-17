#!/bin/bash

# Main installation script for CPU-based web scraper
echo "Starting installation of CPU-based web scraper..."

# Step 1: Run cleanup script if GPU version exists
if [ -f "/usr/local/bin/monitor-grid-k2.sh" ]; then
    echo "Detected GPU installation, cleaning up..."
    bash cleanup_gpu_install.sh
fi

# Step 2: Run CPU setup script
echo "Setting up CPU-optimized environment..."
bash setup_cpu.sh

# Step 3: Wait for Ollama service to start
echo "Waiting for Ollama service to start..."
sleep 10

# Step 4: Pull the LLM model
echo "Pulling the LLM model..."
ollama pull huihui_ai/phi4-abliterated:14b-q8_0

# Step 5: Create application directory
mkdir -p /opt/scraper-app
cd /opt/scraper-app

# Step 6: Start the web application
echo "Starting the web application..."
npm install
npm run build
npm run preview -- --host 77.237.11.39 --port 4040

echo "Installation complete! Access the web interface at http://77.237.11.39:4040"