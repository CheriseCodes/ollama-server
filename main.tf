terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main internet gateway"
  }
}

resource "aws_subnet" "main_public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = format("%va", var.aws_region)
  tags = {
    Name = "Main public subnet"
  }
}

resource "aws_security_group" "allow_internet_egress" {
  name        = "allow_tls"
  description = "Allow outbound internet traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_ollama" {
  name        = "allow_ollama"
  description = "Allow inbound requests to ollama"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Allow Ollama access from local machine"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ollama_shh" {
  security_group_id = aws_security_group.allow_ollama.id
  cidr_ipv4         = format("%v/32", var.local_ip)
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_download_https" {
  security_group_id = aws_security_group.allow_internet_egress.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_download_http" {
  security_group_id = aws_security_group.allow_internet_egress.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ollama_endpoint" {
  security_group_id = aws_security_group.allow_ollama.id
  cidr_ipv4         = format("%v/32", var.local_ip)
  from_port         = 11434
  ip_protocol       = "tcp"
  to_port           = 11434
}

resource "aws_route_table" "internet_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Internet access route table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id      = aws_subnet.main_public.id
  route_table_id = aws_route_table.internet_rt.id
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  user_data                   = file("./scripts/startup.sh")
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_public.id
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.allow_internet_egress.id, aws_security_group.allow_ollama.id]
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "ollama-server"
  }
}
