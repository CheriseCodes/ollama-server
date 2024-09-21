#!/bin/bash
set -x
export HOME=/home/ubuntu
curl -fsSL https://ollama.com/install.sh | sed 's/Environment="\PATH=$PATH\"/Environment=\"OLLAMA_HOST=0.0.0.0\"/g' | sh
systemctl daemon-reload
systemctl restart ollama.service
ollama pull gemma2
ollama pull mistral
ollama pull llama3.1
