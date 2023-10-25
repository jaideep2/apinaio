#!/bin/sh

# Start web server
ollama serve &
sleep 5

# Create Model
ollama create mj -f /app/modelfiles/modelfile_midjourney
sleep 5
echo "Model Created, enjoy!"

tail -f /dev/null