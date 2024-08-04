output "ssh_command" {
  value = format("ssh -i %v.pem ubuntu@%v", aws_instance.web.key_name, aws_instance.web.public_dns)
}
