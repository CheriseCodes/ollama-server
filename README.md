# Run an Ollama server on AWS using Terraform

# How to Deploy
1. Create a `custom.tfvars` file with defined variables detailed in `inputs.tf`
2. Run `terraform plan -var-file="custom.tfvars"`
3. Once satisfied with the plan run `terraform apply -var-file="custom.tfvars"`

## Limitations
- It may take a few minutes after `terraform apply` finishes for Ollama to be up and running. You can run `cloud-init status --wait` to confirm that User Data script has finished running.
- Before running the tests below, you will need to ssh into the server and edit `ollama.service` like so:
```
sudo systemctl edit ollama.service

### config to add
[Service] 
Environment="OLLAMA_HOST=0.0.0.0"

sudo systemctl daemon-reload
sudo systemctl restart ollama
```

## Tests
From your local machine can now run command like: 
```
curl http://<ec2_public_dns>:11434/api/generate -d '{
  "model": "llama3.1",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```