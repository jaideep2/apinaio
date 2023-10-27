#!/bin/sh

echo "Starting web server"
ollama serve &
sleep 5

echo "Starting essay model"
ollama create es -f /app/modelfiles/modelfile_es
sleep 4

echo "Starting sd model"
ollama create sd -f /app/modelfiles/modelfile_sd
sleep 3

echo "Done!"

tail -f /dev/null