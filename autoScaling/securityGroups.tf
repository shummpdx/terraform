# Allow SSH access
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  vpc_id = aws_vpc.autoscaling_vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sshSecurity"
  }
}

# Allow traffic into the VPC
resource "aws_security_group" "outboundTraffic" {
  name = "outboundTraffic"
  description = "Allow for outbound traffic"
  vpc_id = aws_vpc.autoscaling_vpc.id

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}