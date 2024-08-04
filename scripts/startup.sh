#!/bin/bash
set -x
export HOME=/home/ubuntu
curl -fsSL https://ollama.com/install.sh | sh
ollama pull gemma2
ollama pull mistral
ollama pull llama3.1