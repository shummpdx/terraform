resource "aws_instance" "variable_instance" {
  ami           = "ami-00ee4df451840fa9d"
  instance_type = var.instance_type

  tags = {
    Name = "Variable Server"
  }
}