#!/bin/sh

./bin/ollama serve &

sleep 5

curl -X POST http://ollama:11434/api/pull -d '{"name": "llama2"}'

sleep 10

tail -f /dev/null