#!/bin/bash

# Stop current services
echo "Stopping current services..."
systemctl stop ollama
npm run preview -- --host 0.0.0.0 --port 4040 & PID=$!
kill $PID

# Pull latest code from GitHub
echo "Pulling latest code..."
cd /opt/scraper-app
git pull origin main

# Reinstall dependencies and rebuild
echo "Updating dependencies..."
npm install
npm run build

# Restart Ollama service
echo "Restarting services..."
systemctl start ollama
sleep 15  # Wait for Ollama to fully start

# Start the web application
echo "Starting web application..."
npm run preview -- --host 0.0.0.0 --port 4040

echo "Update complete! Application is running at http://localhost:4040"