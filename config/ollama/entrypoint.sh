#!/bin/sh

# Start web server
ollama serve &
sleep 5

echo "Creating Model, will take some time..."
# Create Model
ollama create mj -f /app/modelfiles/modelfile_midjourney
sleep 5
echo "Model Created, enjoy!"

sleep 5
tail -f /dev/null