# Allow SSH access
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  vpc_id = aws_vpc.zodiark.id
  
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

# Allow HTTP access
resource "aws_security_group" "httpSecurity" {
  name = "httpSecurity"
  description = "Zodiark Allows HTTP"
  vpc_id = aws_vpc.zodiark.id
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpSecurity"
  }
}

resource "aws_security_group" "httpsSecurity" {
  name = "httpsSecurity"
  description = "Zodiark Allows HTTPS"
  vpc_id = aws_vpc.zodiark.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpsSecurity"
  }
}

# Allow traffic into the VPC
resource "aws_security_group" "outboundTraffic" {
  name = "outboundTraffic"
  description = "Allow for outbound traffic"
  vpc_id = aws_vpc.zodiark.id

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}