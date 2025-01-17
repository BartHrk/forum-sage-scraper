#!/bin/bash

# Main installation script for CPU-based web scraper
echo "Starting installation of CPU-based web scraper..."

# Step 1: Run cleanup script
echo "Cleaning up any existing installation..."
bash cleanup_gpu_install.sh

# Step 2: Run CPU setup script
echo "Setting up CPU-optimized environment..."
bash setup_cpu.sh

# Step 3: Wait for Ollama service to be fully operational
echo "Waiting for Ollama service to start..."
sleep 15

# Step 4: Pull the LLM model
echo "Pulling the LLM model..."
ollama pull huihui_ai/phi4-abliterated:14b-q8_0

# Step 5: Create application directory and set permissions
echo "Setting up application directory..."
mkdir -p /opt/scraper-app
chmod 755 /opt/scraper-app

# Step 6: Start the web application
echo "Starting the web application..."
cd /opt/scraper-app
npm install
npm run build
npm run preview -- --host 0.0.0.0 --port 4040

echo "Installation complete! Access the web interface at http://localhost:4040"