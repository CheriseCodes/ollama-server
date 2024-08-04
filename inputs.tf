variable "local_ip" {
  type        = string
  description = "The IP of the computer that can SSH into the server"
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "The AWS region to run the server in"
  default     = "ca-central-1"
  nullable    = false
}

variable "aws_profile" {
  type        = string
  description = "AWS profile that holds authentication settings"
  default     = "default"
  nullable    = false
}

variable "key_pair_name" {
  type        = string
  description = "Name of EC2 keypair to SSH into the server"
  nullable    = true
}

variable "volume_size" {
  type        = number
  description = "The amount of space on the Ollama server"
  default     = 50
  nullable    = false
}

variable "instance_type" {
  type        = string
  description = "The type of EC2 instance used by the Ollama server"
  default     = "g4dn.xlarge"
  validation {
    condition     = contains(["g4dn.xlarge", "g4dn.2xlarge", "g4dn.4xlarge", "g4dn.8xlarge", "g4dn.16xlarge", "g4dn.12xlarge", "g4dn.metal"], var.instance_type)
    error_message = "An Nvidia enabled instance type must be used. Valid values for var: instance_type are (g4dn.xlarge, g4dn.2xlarge, g4dn.4xlarge, g4dn.8xlarge, g4dn.16xlarge, g4dn.12xlarge, g4dn.metal)."
  }
  nullable = false
}
