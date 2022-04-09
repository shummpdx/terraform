output "instance_ip" {
  value = aws_instance.variable_instance.public_ip
}