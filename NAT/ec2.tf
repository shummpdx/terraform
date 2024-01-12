# Build our Configured EC2 Instance
resource "aws_instance" "zodiark_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.zodiarks_public_a.id
    private_ip = "10.0.1.213"
    key_name = "ec2Key" 

    # Typically, post-configuration should be left to tools such
    # ansible, but essential bootstrap commands or custom routes
    # for instances in private subnets are reasons why you might
    # need to use this hook.
    user_data = <<EOF
      #! /usr/bin/env bash
      sudo ec2-user
      sudo yum install httpd -y
      sudo service httpd start
    EOF

    security_groups = [
        "${aws_security_group.sshSecurity.id}",
        "${aws_security_group.httpSecurity.id}",
        "${aws_security_group.httpsSecurity.id}",
        "${aws_security_group.outboundTraffic.id}"
    ]
    
    tags = {
        Name = "Public"
    }
}

# Create a private instance
resource "aws_instance" "zodiark_privates" {
  ami = "ami-0359b3157f016ae46"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.zodiarks_private_a.id
  private_ip = "10.0.4.47"

  security_groups = [
        "${aws_security_group.sshSecurity.id}",
        "${aws_security_group.outboundTraffic.id}"
  ]

  key_name = "ec2Key"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name 

  user_data = <<EOF
    #! /usr/bin/env bash
    sudo su
    echo -e "newpass\nnewpass" | passwd ec2-user
    sudo sed -i "/^PasswordAuthentication no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart
  EOF

  tags= {
    Name = "Private"
  }
}

# Guacamole Instance
# Must accept terms/cond. to use resource 
resource "aws_instance" "guacamole" {
  ami = "ami-05764e7636cb4a33d"
  instance_type = "t2.small"
  subnet_id = aws_subnet.zodiarks_public_a.id
  private_ip = "10.0.1.21"
  iam_instance_profile = aws_iam_instance_profile.guacProfile.name

  security_groups = [
    "${aws_security_group.sshSecurity.id}",
    "${aws_security_group.httpSecurity.id}",
    "${aws_security_group.httpsSecurity.id}",
    "${aws_security_group.outboundTraffic.id}"
  ]

  tags = {
      Name = "Guaca!"
    }
}