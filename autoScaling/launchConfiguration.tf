resource "aws_launch_configuration" "as_conf" {
  name = "web_config"
  image_id = "ami-0ca285d4c2cda3300"
  instance_type = "t2.micro"
  security_groups = [
          "${aws_security_group.sshSecurity.id}",
          "${aws_security_group.outboundTraffic.id}"
  ]
  key_name = "ec2Key"
  associate_public_ip_address = true
}