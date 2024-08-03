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
